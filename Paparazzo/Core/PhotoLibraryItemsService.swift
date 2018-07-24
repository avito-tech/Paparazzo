import Photos
import ImageSource

protocol PhotoLibraryItemsService {
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(in: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryAlbumEvent) -> ())
}

enum PhotosOrder {
    case normal
    case reversed
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {
    
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
    init(photosOrder: PhotosOrder = .normal) {
        self.photosOrder = photosOrder
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        onAuthorizationStatusChange = handler
        callAuthorizationHandler(for: PHPhotoLibrary.authorizationStatus())
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
                
                if let changeDetails = change.changeDetails(for: fetchResult.phFetchResult) {
                    
                    fetchResult.phFetchResult = changeDetails.fetchResultAfterChanges
                    
                    changeDetails.removedIndexes?.reversed().forEach { index in
                        fetchResult.albums.remove(at: index)
                    }
                    
                    changeDetails.insertedIndexes?.enumerated()
                        .map { ($1, changeDetails.insertedObjects[$0]) }
                        .forEach { insertionIndex, assetCollection in
                            let album = PhotoLibraryAlbum(assetCollection: assetCollection)
                            fetchResult.albums.insert(album, at: insertionIndex)
                        }
                    
                    changeDetails.changedIndexes?.enumerated()
                        .map { ($1, changeDetails.changedObjects[$0]) }
                        .forEach { changingIndex, assetCollection in
                            let album = PhotoLibraryAlbum(assetCollection: assetCollection)
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
        
        switch PHPhotoLibrary.authorizationStatus() {
        
        case .authorized:
            wasSetUp = true
            setUpFetchResult(completion: completion)
        
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                
                DispatchQueue.main.async {
                    self?.callAuthorizationHandler(for: status)
                    self?.wasSetUp = true
                }
                
                if case .authorized = status {
                    self?.setUpFetchResult(completion: completion)
                } else {
                    DispatchQueue.main.async(execute: completion)
                }
            }
            
        case .restricted, .denied:
            wasSetUp = true
            completion()
        }
    }
    
    private func setUpFetchResult(completion: @escaping () -> ()) {
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
    
    private func callAuthorizationHandler(for status: PHAuthorizationStatus) {
        onAuthorizationStatusChange?(status == .authorized)
    }

    private func callObserverHandler(changes phChanges: PHFetchResultChangeDetails<PHAsset>?) {
        if let phChanges = phChanges, phChanges.hasIncrementalChanges {
            onAlbumEvent?(.incrementalChanges(photoLibraryChanges(from: phChanges)))
        } else {
            onAlbumEvent?(.fullReload(photoLibraryItems(from: assetsFromFetchResult())))
        }
    }
    
    private func assetsFromFetchResult() -> [PHAsset] {
        var images = [PHAsset]()
        observedAlbum?.fetchResult.enumerateObjects(options: enumerationOptions()) { asset, _, _ in
            images.append(asset)
        }
        return images
    }
    
    private func enumerationOptions() -> NSEnumerationOptions {
        switch photosOrder {
        case .normal:
            return []
        case .reversed:
            return [.reverse]
        }
    }
    
    private func photoLibraryItems(from assets: [PHAsset]) -> [PhotoLibraryItem] {
        return assets.map(photoLibraryItem)
    }
    
    private func photoLibraryItem(from asset: PHAsset) -> PhotoLibraryItem {
        return PhotoLibraryItem(
            identifier: asset.localIdentifier,
            image: PHAssetImageSource(asset: asset, imageManager: imageManager)
        )
    }
    
    // TODO: extract to a separate class (e.g. PhotoLibraryChangesBuilder) and write tests
    func photoLibraryChanges(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> PhotoLibraryChanges
    {
        var assetsAfterChanges = [PHAsset]()
        
        changes.fetchResultAfterChanges.enumerateObjects(options: enumerationOptions()) { asset, _, _ in
            assetsAfterChanges.append(asset)
        }
        
        return PhotoLibraryChanges(
            removedIndexes: removedIndexes(from: changes),
            insertedItems: insertedObjects(from: changes),
            updatedItems: updatedObjects(from: changes),
            movedIndexes: movedIndexes(from: changes),
            itemsAfterChanges: photoLibraryItems(from: assetsAfterChanges)
        )
    }
    
    private func removedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
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
    
    private func insertedObjects(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        /*
         To clarify the code below:
         
         `insertionIndex` — index used to map `changes.insertedIndexes` to `changes.insertedObjects`.
         
         `targetAssetIndex` — target index at which asset has been inserted to photo library
             as reported to us by PhotoKit. We will change it if `photosOrder` is `.reversed`.
         
         `finalAssetIndex` — actual target index at which collection view cell for the asset will be inserted.
         */
        return changes.insertedIndexes?.enumerated().map {
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
        } ?? []
    }
    
    private func updatedObjects(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        var updatedObjects = [(index: Int, item: PhotoLibraryItem)]()
        var updatedObjectIndex = changes.changedObjects.count - 1
        let enumeratedIndexes: AnySequence<Int>?
        let realIndexOf: (Int) -> Int
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        switch photosOrder {
        case .normal:
            enumeratedIndexes = (changes.changedIndexes?.reversed()).flatMap { AnySequence($0) }
            realIndexOf = { $0 }
        case .reversed:
            enumeratedIndexes = changes.changedIndexes.flatMap { AnySequence($0) }
            realIndexOf = { objectsCountAfterRemovalsAndInsertions - $0 - 1 }
        }
        
        enumeratedIndexes?.forEach { index in
            guard updatedObjectIndex >= 0 else { return }
            let asset = changes.changedObjects[updatedObjectIndex]
            updatedObjects.append((index: realIndexOf(index), item: self.photoLibraryItem(from: asset)))
            updatedObjectIndex -= 1
        }
        
        return updatedObjects
    }
    
    private func movedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
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
    
    private func allAlbums() -> [PhotoLibraryAlbum] {
        
        var albums = fetchResults.flatMap { $0.albums }
        
        // "All Photos" album should be the first one.
        if let allPhotosAlbumIndex = albums.index(where: { $0.isAllPhotos }), allPhotosAlbumIndex > 0 {
            albums.insert(albums.remove(at: allPhotosAlbumIndex), at: 0)
        }
        
        return albums
    }
}

private final class PhotoLibraryFetchResult {
    
    // MARK: - Data
    var albums: [PhotoLibraryAlbum]
    var phFetchResult: PHFetchResult<PHAssetCollection>
    
    // MARK: - Init
    init(albums: [PhotoLibraryAlbum], phFetchResult: PHFetchResult<PHAssetCollection>) {
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
    
    fileprivate convenience init(assetCollection: PHAssetCollection) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        if #available(iOS 9.0, *) {
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        }
        
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
