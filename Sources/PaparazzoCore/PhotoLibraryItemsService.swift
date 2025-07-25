import Photos
import ImageSource


protocol PhotoLibraryItemsService: AnyObject {
    var onLimitedAccess: (() -> ())? { get set }
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeLimitedAccess(handler: @escaping () -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(in: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryAlbumEvent) -> ())
}

enum PhotosOrder {
    case normal
    case reversed
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {
    var onLimitedAccess: (() -> ())?
    
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
                            let album = PhotoLibraryAlbum(
                                photosOrder: self.photosOrder,
                                assetCollection: assetCollection
                            )
                            fetchResult.albums.insert(album, at: insertionIndex)
                        }
                    
                    changeDetails.changedIndexes?.enumerated()
                        .map { ($1, changeDetails.changedObjects[$0]) }
                        .forEach { changingIndex, assetCollection in
                            let album = PhotoLibraryAlbum(
                                photosOrder: self.photosOrder,
                                assetCollection: assetCollection
                            )
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
            setUpFetchResult(completion: completion)

            #if compiler(>=5.3)
            // Xcode 12+
        case .limited:
            wasSetUp = true
            setUpFetchResult(completion: completion)
            
            onLimitedAccess?()
            #endif
        
        case .notDetermined:
            PHPhotoLibrary.requestReadWriteAuthorization { [weak self] status in
                
                DispatchQueue.main.async {
                    self?.callAuthorizationHandler(for: status)
                    self?.wasSetUp = true
                }
                
                switch status {
                case .authorized:
                    self?.setUpFetchResult(completion: completion)
                #if compiler(>=5.3)
                case .limited:
                    self?.setUpFetchResult(completion: completion)
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
                    albums.append(PhotoLibraryAlbum(
                        photosOrder: self.photosOrder,
                        assetCollection: collection
                    ))
                })
                
                fetchResults.append(PhotoLibraryFetchResult(albums: albums, phFetchResult: collectionsFetchResult))
            }
            
            self.fetchResults = fetchResults
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
            
            let albums = [PhotoLibraryAlbum(
                photosOrder: self.photosOrder,
                assetCollection: assetCollection
            )]
            
            self.fetchResults = [PhotoLibraryFetchResult(albums: albums, phFetchResult: nil)]
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func callAuthorizationHandler(for status: PHAuthorizationStatus) {
        onAuthorizationStatusChange?(status.isAuthorizedOrLimited)
    }

    private func callObserverHandler(changes phChanges: PHFetchResultChangeDetails<PHAsset>?) {
        if let phChanges = phChanges, phChanges.hasIncrementalChanges {
            if authorizationStatus == .limited {
                onAlbumEvent?(.fullReload(photoLibraryChanges(from: phChanges).itemsAfterChanges))
            } else {
                onAlbumEvent?(.incrementalChanges(photoLibraryChanges(from: phChanges)))
            }
        } else if let observedAlbum = observedAlbum {
            onAlbumEvent?(.fullReload(photoLibraryItems(from: observedAlbum.fetchResult)))
        } else {
            onAlbumEvent?(.fullReload([]))
        }
    }
    
    // MARK: - Photo library items
    
    private func photoLibraryItems(from fetchResult: PHFetchResult<PHAsset>) -> [PhotoLibraryItem] {
        let indexes = 0 ..< fetchResult.count
        
        return indexes.map { indexInFetchResult in
            PhotoLibraryItem(
                image: PHAssetImageSource(
                    fetchResult: fetchResult,
                    index: indexInFetchResult,
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
        return PhotoLibraryChanges(
            removedIndexes: removedIndexes(from: changes),
            insertedItems: insertedObjects(from: changes),
            updatedItems: updatedObjects(from: changes),
            movedIndexes: movedIndexes(from: changes),
            itemsAfterChanges: photoLibraryItems(from: changes.fetchResultAfterChanges)
        )
    }
    
    // MARK: - Remove
    
    private func removedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>) -> IndexSet {
        var removedIndexes = IndexSet()
        
        changes.removedIndexes?.reversed().forEach { index in
            removedIndexes.insert(index)
        }

        return removedIndexes
    }

    
    // MARK: - Insert
    
    private func insertedObjects(from changes: PHFetchResultChangeDetails<PHAsset>) -> [(index: Int, item: PhotoLibraryItem)] {
        guard let insertedIndexes = changes.insertedIndexes else { return [] }
        
        return insertedIndexes.enumerated().map { insertionIndex, targetAssetIndex -> (index: Int, item: PhotoLibraryItem) in
            let asset = changes.insertedObjects[insertionIndex]
            return (index: targetAssetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    // MARK: - Update
    
    private func updatedObjects(from changes: PHFetchResultChangeDetails<PHAsset>) -> [(index: Int, item: PhotoLibraryItem)] {
        guard let changedIndexes = changes.changedIndexes else { return [] }
        
        return changedIndexes.enumerated().map { changeIndex, assetIndex -> (index: Int, item: PhotoLibraryItem) in
            let asset = changes.changedObjects[changeIndex]
            return (index: assetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    // MARK: - Moved
    
    private func movedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>) -> [(from: Int, to: Int)] {
        var movedIndexes = [(from: Int, to: Int)]()
        
        changes.enumerateMoves { (from, to) in
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
    
    fileprivate convenience init(
        photosOrder: PhotosOrder,
        assetCollection: PHAssetCollection
    ) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: photosOrder == .normal)]
        fetchOptions.fetchLimit = 10_000
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
