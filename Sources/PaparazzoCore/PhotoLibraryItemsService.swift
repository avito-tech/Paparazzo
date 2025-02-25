import Photos
import ImageSource


protocol PhotoLibraryItemsService: AnyObject {
    var onLimitedAccess: (() -> ())? { get set }
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeLimitedAccess(handler: @escaping () -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(in: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryAlbumEvent) -> ())
    
    func photoLibraryItems(numberOfDisplayedItems: Int) -> [PhotoLibraryItem]
}

enum PhotosOrder {
    case normal
    case reversed
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {
    // MARK: - Spec
    private enum Spec {
        static let debugItemsPerPage = 50
        static let releaseItemsPerPage = 1000
    }
    
    var onLimitedAccess: (() -> ())?
    
    private let isPresentingPhotosFromCameraFixEnabled: Bool
    private let isPhotoFetchingByPageEnabled: Bool
    private let photosOrder: PhotosOrder
    private let photoLibrary = PHPhotoLibrary.shared()
    private var fetchResults = [PhotoLibraryFetchResult]()
    
    private let fetchResultQueue = DispatchQueue(
        label: "ru.avito.Paparazzo.PhotoLibraryItemsServiceImpl.fetchResultQueue",
        qos: .userInitiated
    )
    
    // lazy because if you create PHImageManager immediately
    // the app will crash on dealloc of this class if access to photo library is denied
    private lazy var imageManager = PHImageManager()
    
    // MARK: - Init
    init(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        photosOrder: PhotosOrder = .normal
    ) {
        self.isPresentingPhotosFromCameraFixEnabled = isPresentingPhotosFromCameraFixEnabled
        self.isPhotoFetchingByPageEnabled = isPhotoFetchingByPageEnabled
        self.photosOrder = photosOrder
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    private var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.readWriteAuthorizationStatus()
    }
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        onAuthorizationStatusChange = handler
        callAuthorizationHandler(for: authorizationStatus)
    }
    
    func observeLimitedAccess(handler: @escaping () -> ()) {
        onLimitedAccess = handler
        #if compiler(>=5.3)
        if authorizationStatus == .limited {
            onLimitedAccess?()
        }
        #endif
    }

    
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ()) {
        executeAfterSetup {
            self.onAlbumsChange = handler
            handler(self.allAlbums())
        }
    }
    
    func observeEvents(in album: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryAlbumEvent) -> ()) {
        executeAfterSetup {
            self.observedAlbum = album
            self.onAlbumEvent = handler
            self.callObserverHandler(changes: nil)
        }
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ change: PHChange) {
        fetchResultQueue.async {
            guard self.fetchResults.count > 0 else { return }
            
            var needToReportAlbumsChange = false
            
            self.fetchResults.forEach { fetchResult in
                
                // We need to enumerate all the fetched albums:
                // 1) to keep their content in sync with photo library without refething
                // 2) to check if album cover has changed
                fetchResult.albums = fetchResult.albums.map { album in
                    guard let changeDetails = change.changeDetails(for: album.fetchResult) else { return album }
                    
                    var album = album
                    album.fetchResult = changeDetails.fetchResultAfterChanges
                    
                    let lastAssetImageSource = album.fetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) }
                    
                    if album.coverImage != lastAssetImageSource {
                        // Album cover need to be changed
                        album = album.changingCoverImage(to: lastAssetImageSource)
                        needToReportAlbumsChange = true
                    }
                    
                    if album == self.observedAlbum {
                        // Report changes in the observed album
                        DispatchQueue.main.async {
                            self.callObserverHandler(changes: changeDetails)
                        }
                    }
                    
                    return album
                }
                
                if let collectionFetchResult = fetchResult.phFetchResult,
                   let changeDetails = change.changeDetails(for: collectionFetchResult)
                {
                    fetchResult.phFetchResult = changeDetails.fetchResultAfterChanges
                    
                    changeDetails.removedIndexes?.reversed().forEach { index in
                        fetchResult.albums.remove(at: index)
                    }
                    
                    changeDetails.insertedIndexes?.enumerated()
                        .map { ($1, changeDetails.insertedObjects[$0]) }
                        .forEach { insertionIndex, assetCollection in
                            let album = self.isPhotoFetchingByPageEnabled
                                ? PhotoLibraryAlbum(assetCollection: assetCollection, ascending: self.photosOrder == .normal)
                                : PhotoLibraryAlbum(assetCollection: assetCollection)
                            fetchResult.albums.insert(album, at: insertionIndex)
                        }
                    
                    changeDetails.changedIndexes?.enumerated()
                        .map { ($1, changeDetails.changedObjects[$0]) }
                        .forEach { changingIndex, assetCollection in
                            let album = self.isPhotoFetchingByPageEnabled
                                ? PhotoLibraryAlbum(assetCollection: assetCollection, ascending: self.photosOrder == .normal)
                                : PhotoLibraryAlbum(assetCollection: assetCollection)
                            fetchResult.albums[changingIndex] = album
                        }
                    
                    // Moves: seems like iOS doesn't generate them for photo albums
                    
                    needToReportAlbumsChange = true
                }
            }
            
            if needToReportAlbumsChange {
                let albums = self.allAlbums()
                DispatchQueue.main.async {
                    self.onAlbumsChange?(albums)
                }
            }
        }
    }

    // MARK: - Private
    
    private var onAlbumEvent: ((PhotoLibraryAlbumEvent) -> ())?
    private var onAlbumsChange: (([PhotoLibraryAlbum]) -> ())?
    private var onAuthorizationStatusChange: ((_ accessGranted: Bool) -> ())?
    
    private var observedAlbum: PhotoLibraryAlbum?
    private var wasSetUp = false
    
    /// `completion` is executed on main queue
    private func executeAfterSetup(completion: @escaping () -> ()) {
        
        guard !wasSetUp else {
            completion()
            return
        }
        
        switch authorizationStatus {
        
        case .authorized:
            wasSetUp = true
            isPhotoFetchingByPageEnabled
                ? setUpFetchResult(completion: completion)
                : setUpFetchResultLegacy(completion: completion)

            #if compiler(>=5.3)
            // Xcode 12+
        case .limited:
            wasSetUp = true
            if isPresentingPhotosFromCameraFixEnabled {
                isPhotoFetchingByPageEnabled
                    ? setUpFetchResult(completion: completion)
                    : setUpFetchResultLegacy(completion: completion)
            } else {
                isPhotoFetchingByPageEnabled
                    ? setUpFetchResultForLimitedAccess(completion: completion)
                    : setUpFetchResultForLimitedAccessLegacy(completion: completion)
            }
            
            onLimitedAccess?()
            #endif
        
        case .notDetermined:
            PHPhotoLibrary.requestReadWriteAuthorization { [weak self] status in
                guard let self else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.callAuthorizationHandler(for: status)
                    self?.wasSetUp = true
                }
                
                switch status {
                case .authorized:
                    self.isPhotoFetchingByPageEnabled
                        ? self.setUpFetchResult(completion: completion)
                        : self.setUpFetchResultLegacy(completion: completion)
                #if compiler(>=5.3)
                case .limited:
                    if self.isPresentingPhotosFromCameraFixEnabled {
                        self.setUpFetchResult(completion: completion)
                    } else {
                        self.isPhotoFetchingByPageEnabled
                            ? self.setUpFetchResultForLimitedAccess(completion: completion)
                            : self.setUpFetchResultForLimitedAccessLegacy(completion: completion)
                    }
                #endif
                default:
                    DispatchQueue.main.async(execute: completion)
                }
            }
            
        case .restricted, .denied:
            wasSetUp = true
            completion()
        
        @unknown default:
            assertionFailure("Unknown authorization status")
            wasSetUp = true
            completion()
        }
    }
    
    @available(*, deprecated, message: "Use `setUpFetchResult` instead.")
    // Не нужно сортировать каждый раз и использовать photosOrder, так как это происходит на этапе загрузки фотографий
    private func setUpFetchResultLegacy(completion: @escaping () -> ()) {
        fetchResultQueue.async {
            
            var fetchResults = [PhotoLibraryFetchResult]()
            
            let collectionsFetchResults = [
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil),
                PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            ]
            
            collectionsFetchResults.enumerated().forEach { index, collectionsFetchResult in
                
                var albums = [PhotoLibraryAlbum]()
                
                collectionsFetchResult.enumerateObjects(using: { collection, _, _ in
                    albums.append(PhotoLibraryAlbum(assetCollection: collection))
                })
                
                fetchResults.append(PhotoLibraryFetchResult(albums: albums, phFetchResult: collectionsFetchResult))
            }
            
            self.fetchResults = fetchResults
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func setUpFetchResult(completion: @escaping () -> ()) {
        fetchResultQueue.async { [weak self] in
            guard let self else { return }
            
            var fetchResults = [PhotoLibraryFetchResult]()
            
            let collectionsFetchResults = [
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil),
                PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            ]
            
            collectionsFetchResults.enumerated().forEach { index, collectionsFetchResult in
                var albums = [PhotoLibraryAlbum]()
                
                collectionsFetchResult.enumerateObjects(using: { collection, _, _ in
                    albums.append(PhotoLibraryAlbum(assetCollection: collection, ascending: self.photosOrder == .normal))
                })
                
                fetchResults.append(PhotoLibraryFetchResult(albums: albums, phFetchResult: collectionsFetchResult))
            }
            
            self.fetchResults = fetchResults
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    @available(*, deprecated, message: "Use `setUpFetchResultForLimitedAccess` instead.")
    // Не нужно сортировать каждый раз и использовать photosOrder, так как это происходит на этапе загрузки фотографий
    private func setUpFetchResultForLimitedAccessLegacy(completion: @escaping () -> ()) {
        fetchResultQueue.async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced]
            
            let assetsFetchResult = PHAsset.fetchAssets(with: fetchOptions)
            
            let assetCollection = PHAssetCollection.transientAssetCollection(
                withAssetFetchResult: assetsFetchResult,
                title: localized("All photos")
            )
            
            let albums = [PhotoLibraryAlbum(assetCollection: assetCollection)]
            
            self.fetchResults = [PhotoLibraryFetchResult(albums: albums, phFetchResult: nil)]
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func setUpFetchResultForLimitedAccess(completion: @escaping () -> ()) {
        fetchResultQueue.async { [weak self] in
            guard let self else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced]
            
            let assetsFetchResult = PHAsset.fetchAssets(with: fetchOptions)
            
            let assetCollection = PHAssetCollection.transientAssetCollection(
                withAssetFetchResult: assetsFetchResult,
                title: localized("All photos")
            )
            
            let albums = [PhotoLibraryAlbum(assetCollection: assetCollection, ascending: self.photosOrder == .normal)]
            
            self.fetchResults = [PhotoLibraryFetchResult(albums: albums, phFetchResult: nil)]
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func callAuthorizationHandler(for status: PHAuthorizationStatus) {
        onAuthorizationStatusChange?(status.isAuthorizedOrLimited)
    }

    private func callObserverHandler(changes phChanges: PHFetchResultChangeDetails<PHAsset>?) {
        if isPresentingPhotosFromCameraFixEnabled {
            if let phChanges = phChanges, phChanges.hasIncrementalChanges {
                if authorizationStatus == .limited {
                    onAlbumEvent?(.fullReload(photoLibraryChanges(from: phChanges).itemsAfterChanges))
                } else {
                    onAlbumEvent?(.incrementalChanges(photoLibraryChanges(from: phChanges)))
                }
            } else if let observedAlbum = observedAlbum {
                if isPhotoFetchingByPageEnabled {
                    onAlbumEvent?(.fullReload(photoLibraryItems(numberOfDisplayedItems: 0)))
                } else {
                    onAlbumEvent?(.fullReload(photoLibraryItemsLegacy(from: observedAlbum.fetchResult)))
                }
            } else {
                onAlbumEvent?(.fullReload([]))
            }
        } else {
            if let phChanges = phChanges, phChanges.hasIncrementalChanges {
                onAlbumEvent?(.incrementalChanges(photoLibraryChanges(from: phChanges)))
            } else if let observedAlbum = observedAlbum {
                if isPhotoFetchingByPageEnabled {
                    onAlbumEvent?(.fullReload(photoLibraryItems(numberOfDisplayedItems: 0)))
                } else {
                    onAlbumEvent?(.fullReload(photoLibraryItemsLegacy(from: observedAlbum.fetchResult)))
                }
            } else {
                onAlbumEvent?(.fullReload([]))
            }
        }
    }
    
    @available(*, deprecated, message: "Use `photoLibraryItems` instead.")
    // Не нужно сортировать каждый раз и использовать photosOrder, так как это происходит на этапе загрузки фотографий
    private func photoLibraryItemsLegacy(from fetchResult: PHFetchResult<PHAsset>) -> [PhotoLibraryItem] {
        
        let indexes = 0 ..< fetchResult.count
        
        return indexes.map { indexInFetchResult in
            
            let index: Int = {
                switch photosOrder {
                case .normal:
                    return indexInFetchResult
                case .reversed:
                    return indexes.upperBound - indexInFetchResult - 1
                }
            }()
            
            return PhotoLibraryItem(
                image: PHAssetImageSource(
                    fetchResult: fetchResult,
                    index: index,
                    imageManager: imageManager
                )
            )
        }
    }
    
    func photoLibraryItems(numberOfDisplayedItems: Int) -> [PhotoLibraryItem] {
        guard let observedAlbum else { return [] }
        
        if numberOfDisplayedItems > (observedAlbum.fetchResult.count - 1) { return [] }
        
        // Количество фотографий для локального постраничного отображения из галереи
        let itemsPerPage: Int
        #if DEBUG
        itemsPerPage = Spec.debugItemsPerPage
        #else
        itemsPerPage = Spec.releaseItemsPerPage
        #endif
        let startIndex = numberOfDisplayedItems
        let endIndex = min(startIndex + itemsPerPage, observedAlbum.fetchResult.count)
        let indexes = startIndex ..< endIndex
        
        return indexes.map { index in
            PhotoLibraryItem(
                image: PHAssetImageSource(
                    fetchResult: observedAlbum.fetchResult,
                    index: index,
                    imageManager: imageManager
                )
            )
        }
    }
    
    private func photoLibraryItem(from asset: PHAsset) -> PhotoLibraryItem {
        return PhotoLibraryItem(
            image: PHAssetImageSource(asset: asset, imageManager: imageManager)
        )
    }
    
    // TODO: extract to a separate class (e.g. PhotoLibraryChangesBuilder) and write tests
    func photoLibraryChanges(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> PhotoLibraryChanges
    {
        if isPhotoFetchingByPageEnabled {
            return PhotoLibraryChanges(
                removedIndexes: removedIndexes(from: changes),
                insertedItems: insertedObjects(from: changes),
                updatedItems: updatedObjects(from: changes),
                movedIndexes: movedIndexes(from: changes),
                itemsAfterChanges: photoLibraryItemsLegacy(from: changes.fetchResultAfterChanges)
            )
        } else {
            return PhotoLibraryChanges(
                removedIndexes: removedIndexesLegacy(from: changes),
                insertedItems: insertedObjectsLegacy(from: changes),
                updatedItems: updatedObjectsLegacy(from: changes),
                movedIndexes: movedIndexesLegacy(from: changes),
                itemsAfterChanges: photoLibraryItemsLegacy(from: changes.fetchResultAfterChanges)
            )
        }
    }
    
    @available(*, deprecated, message: "Use `removedIndexes` instead.")
    // Не нужно сортировать каждый раз, так как это происходит на этапе загрузки фотографий
    private func removedIndexesLegacy(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> IndexSet
    {
        let assetsCountBeforeChanges = changes.fetchResultBeforeChanges.count
        var removedIndexes = IndexSet()
        
        switch photosOrder {
        case .normal:
            changes.removedIndexes?.reversed().forEach { index in
                removedIndexes.insert(index)
            }
        case .reversed:
            changes.removedIndexes?.forEach { index in
                removedIndexes.insert(assetsCountBeforeChanges - index - 1)
            }
        }
        
        return removedIndexes
    }
    
    private func removedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> IndexSet
    {
        let assetsCountBeforeChanges = changes.fetchResultBeforeChanges.count
        var removedIndexes = IndexSet()
        changes.removedIndexes?.reversed().forEach { index in
            removedIndexes.insert(index)
        }
        
        return removedIndexes
    }
    
    @available(*, deprecated, message: "Use `insertedObjects` instead.")
    // Не нужно сортировать каждый раз, так как это происходит на этапе загрузки фотографий
    private func insertedObjectsLegacy(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        guard let insertedIndexes = changes.insertedIndexes else { return [] }
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        /*
         To clarify the code below:
         
         `insertionIndex` — index used to map `changes.insertedIndexes` to `changes.insertedObjects`.
         
         `targetAssetIndex` — target index at which asset has been inserted to photo library
             as reported to us by PhotoKit.
         
         `finalAssetIndex` — actual target index at which collection view cell for the asset will be inserted.
             This is the same as `targetAssetIndex` if `photosOrder` is `.normal`.
             However if `photosOrder` is `.reversed` we need to do some calculation.
         */
        return insertedIndexes.enumerated().map {
            insertionIndex, targetAssetIndex -> (index: Int, item: PhotoLibraryItem) in
            
            let asset = changes.insertedObjects[insertionIndex]
            
            let finalAssetIndex: Int = {
                switch photosOrder {
                case .normal:
                    return targetAssetIndex
                case .reversed:
                    return objectsCountAfterRemovalsAndInsertions - targetAssetIndex - 1
                }
            }()
            
            return (index: finalAssetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    private func insertedObjects(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        guard let insertedIndexes = changes.insertedIndexes else { return [] }
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        return insertedIndexes.enumerated().map {
            insertionIndex, targetAssetIndex -> (index: Int, item: PhotoLibraryItem) in
            
            let asset = changes.insertedObjects[insertionIndex]
            return (index: targetAssetIndex, item: photoLibraryItem(from: asset))
        }
    }

    
    @available(*, deprecated, message: "Use `updatedObjects` instead.")
    // Не нужно сортировать каждый раз, так как это происходит на этапе загрузки фотографий
    private func updatedObjectsLegacy(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        guard let changedIndexes = changes.changedIndexes else { return [] }
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        /*
         To clarify the code below:
         
         `changeIndex` — index used to map `changes.changedIndexes` to `changes.changedObjects`.

         `assetIndex` — index at which asset has been updated in photo library as reported to us by PhotoKit.
         
         `finalAssetIndex` — actual index of a collection view cell for the asset that will be updated.
             This is the same as `assetIndex` if `photosOrder` is `.normal`.
             However if `photosOrder` is `.reversed` we need to do some calculation.
         */
        return changedIndexes.enumerated().map { changeIndex, assetIndex -> (index: Int, item: PhotoLibraryItem) in
            
            let asset = changes.changedObjects[changeIndex]
            
            let finalAssetIndex: Int = {
                switch photosOrder {
                case .normal:
                    return assetIndex
                case .reversed:
                    return objectsCountAfterRemovalsAndInsertions - assetIndex - 1
                }
            }()
            
            return (index: finalAssetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    private func updatedObjects(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        guard let changedIndexes = changes.changedIndexes else { return [] }
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        return changedIndexes.enumerated().map { changeIndex, assetIndex -> (index: Int, item: PhotoLibraryItem) in
            
            let asset = changes.changedObjects[changeIndex]
            return (index: assetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    @available(*, deprecated, message: "Use `movedIndexes` instead.")
    // Не нужно сортировать каждый раз, так как это происходит на этапе загрузки фотографий
    private func movedIndexesLegacy(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(from: Int, to: Int)]
    {
        var movedIndexes = [(from: Int, to: Int)]()
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        changes.enumerateMoves { from, to in
            
            let (realFrom, realTo): (Int, Int) = {
                switch self.photosOrder {
                case .normal:
                    return (from, to)
                case .reversed:
                    return (
                        objectsCountAfterRemovalsAndInsertions - from - 1,
                        objectsCountAfterRemovalsAndInsertions - to - 1
                    )
                }
            }()
            
            movedIndexes.append((from: realFrom, to: realTo))
        }
        
        return movedIndexes
    }
    
    private func movedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(from: Int, to: Int)]
    {
        var movedIndexes = [(from: Int, to: Int)]()
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        changes.enumerateMoves { from, to in
            movedIndexes.append((from: from, to: to))
        }
        
        return movedIndexes
    }
    
    private func allAlbums() -> [PhotoLibraryAlbum] {
        
        var albums = fetchResults.flatMap { $0.albums }
        
        // "All Photos" album should be the first one.
        if let allPhotosAlbumIndex = albums.firstIndex(where: { $0.isAllPhotos }), allPhotosAlbumIndex > 0 {
            albums.insert(albums.remove(at: allPhotosAlbumIndex), at: 0)
        }
        
        return albums
    }
}

private final class PhotoLibraryFetchResult {
    
    // MARK: - Data
    var albums: [PhotoLibraryAlbum]
    var phFetchResult: PHFetchResult<PHAssetCollection>?
    
    // MARK: - Init
    init(albums: [PhotoLibraryAlbum], phFetchResult: PHFetchResult<PHAssetCollection>?) {
        self.albums = albums
        self.phFetchResult = phFetchResult
    }
}

final class PhotoLibraryAlbum: Equatable {
    
    let identifier: String
    let title: String?
    let coverImage: ImageSource?
    let numberOfItems: Int
    let isAllPhotos: Bool
    
    fileprivate var fetchResult: PHFetchResult<PHAsset>

    private init(
        identifier: String,
        title: String?,
        coverImage: ImageSource?,
        isAllPhotos: Bool,
        fetchResult: PHFetchResult<PHAsset>)
    {
        self.identifier = identifier
        self.title = title
        self.coverImage = coverImage
        self.fetchResult = fetchResult
        self.isAllPhotos = isAllPhotos
        self.numberOfItems = fetchResult.count
    }
    
    @available(*, deprecated, message: "Use init(assetCollection: ascending:)")
    fileprivate convenience init(assetCollection: PHAssetCollection) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        
        self.init(
            identifier: assetCollection.localIdentifier,
            title: assetCollection.localizedTitle,
            coverImage: fetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) },
            isAllPhotos: assetCollection.assetCollectionType == .smartAlbum &&
                         assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary,
            fetchResult: fetchResult
        )
    }
    
    fileprivate convenience init(assetCollection: PHAssetCollection, ascending: Bool) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]

        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        
        self.init(
            identifier: assetCollection.localIdentifier,
            title: assetCollection.localizedTitle,
            coverImage: fetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) },
            isAllPhotos: assetCollection.assetCollectionType == .smartAlbum &&
                         assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary,
            fetchResult: fetchResult
        )
    }
    
    func changingCoverImage(to image: ImageSource?) -> PhotoLibraryAlbum {
        return PhotoLibraryAlbum(
            identifier: identifier,
            title: title,
            coverImage: image,
            isAllPhotos: isAllPhotos,
            fetchResult: fetchResult
        )
    }
    
    static func ==(lhs: PhotoLibraryAlbum, rhs: PhotoLibraryAlbum) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
