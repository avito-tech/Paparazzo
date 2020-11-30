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
    private let allowedMediaTypes: Set<PHAssetMediaType>
    private let photoLibrary = PHPhotoLibrary.shared()
    private var fetchResults = [PhotoLibraryFetchResult]()
    
    private let fetchResultQueue = DispatchQueue(
        label: "ru.avito.Paparazzo.PhotoLibraryItemsServiceImpl.fetchResultQueue",
        qos: .userInitiated
    )
    
    // lazy because if you create PHImageManager immediately
    // the app will crash on dealloc of this class if access to photo library is denied
    private lazy var imageManager = PHImageManager()
    
    private lazy var itemsManager: PhotoLibraryItemsManager = {
        PhotoLibraryItemsManager(photosOrder: photosOrder, allowedMediaTypes: allowedMediaTypes, imageManager: imageManager)
    }()
    
    // MARK: - Init
    init(photosOrder: PhotosOrder = .normal, showVideos: Bool) {
        self.photosOrder = photosOrder
        self.allowedMediaTypes = showVideos ? [.image, .video] : [.image]
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        onAuthorizationStatusChange = handler
        callAuthorizationHandler(for: PHPhotoLibrary.readWriteAuthorizationStatus())
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
        
        switch PHPhotoLibrary.readWriteAuthorizationStatus() {
        
        case .authorized:
            wasSetUp = true
            setUpFetchResult(completion: completion)

            #if compiler(>=5.3)
            // Xcode 12+
        case .limited:
            wasSetUp = true
            setUpFetchResultForLimitedAccess(completion: completion)
            
            #endif
        
        case .notDetermined:
            PHPhotoLibrary.requestReadWriteAuthorization { [weak self] status in
                
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
        
        @unknown default:
            assertionFailure("Unknown authorization status")
            wasSetUp = true
            completion()
        }
    }
    
    private func setUpFetchResult(completion: @escaping () -> ()) {
        fetchResultQueue.async {
            let startDate = Date()
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

            print("setUpFetchResult finished in \(Date().timeIntervalSince(startDate)) seconds")
            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func setUpFetchResultForLimitedAccess(completion: @escaping () -> ()) {
        fetchResultQueue.async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced]
            
            let assetsFetchResult = PHAsset.fetchAssets(with: fetchOptions)
            print("Assets in fetch result: \(assetsFetchResult.count)")
            
            let assetCollection = PHAssetCollection.transientAssetCollection(
                withAssetFetchResult: assetsFetchResult,
                title: localized("All photos")
            )
            print("Transient album id = \(assetCollection.localIdentifier)")
            
            let albums = [PhotoLibraryAlbum(assetCollection: assetCollection)]
            
            self.fetchResults = [PhotoLibraryFetchResult(albums: albums, phFetchResult: nil)]
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func callAuthorizationHandler(for status: PHAuthorizationStatus) {
        let isAccessGranted: Bool = {
            #if compiler(>=5.3)
            // Xcode 12+
            if #available(iOS 14, *) {
                return status == .authorized || status == .limited
            } else {
                return status == .authorized
            }
            #else
            return status == .authorized
            #endif
        }()
        onAuthorizationStatusChange?(isAccessGranted)
    }

    private func callObserverHandler(changes phChanges: PHFetchResultChangeDetails<PHAsset>?) {
        if let phChanges = phChanges, phChanges.hasIncrementalChanges {
            itemsManager.handleChanges(phChanges) { [onAlbumEvent] changes in
                onAlbumEvent?(.incrementalChanges(changes))
            }
        } else if let observedAlbum = observedAlbum {
            let photoLibraryItems = itemsManager.setItems(from: observedAlbum.fetchResult) { [onAlbumEvent] changes in
                onAlbumEvent?(.incrementalChanges(changes))
            }
            onAlbumEvent?(.fullReload(photoLibraryItems))
        } else {
            // TODO: use itemsManager?
            onAlbumEvent?(.fullReload([]))
        }
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
    
    fileprivate convenience init(assetCollection: PHAssetCollection) {
        
        let fetchOptions = PHFetchOptions()
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
