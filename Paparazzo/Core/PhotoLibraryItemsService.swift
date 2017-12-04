import Photos
import ImageSource

protocol PhotoLibraryItemsService {
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(in: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryAlbumEvent) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {
    
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
                            let album = self.photoLibraryAlbum(from: assetCollection)
                            fetchResult.albums.insert(album, at: insertionIndex)
                        }
                    
                    changeDetails.changedIndexes?.enumerated()
                        .map { ($1, changeDetails.changedObjects[$0]) }
                        .forEach { changingIndex, assetCollection in
                            let album = self.photoLibraryAlbum(from: assetCollection)
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
                    albums.append(self.photoLibraryAlbum(from: collection))
                })
                
                fetchResults.append(PhotoLibraryFetchResult(albums: albums, phFetchResult: collectionsFetchResult))
            }
            
            self.fetchResults = fetchResults
            self.photoLibrary.register(self)

            DispatchQueue.main.async(execute: completion)
        }
    }
    
    private func photoLibraryAlbum(identifier: String, title: String?, fetchResult: PHFetchResult<PHAsset>)
        -> PhotoLibraryAlbum
    {
        return PhotoLibraryAlbum(
            identifier: identifier,
            title: title,
            coverImage: fetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) },
            fetchResult: fetchResult
        )
    }
    
    private func photoLibraryAlbum(from assetCollection: PHAssetCollection)
        -> PhotoLibraryAlbum
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        if #available(iOS 9.0, *) {
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        }
        
        return photoLibraryAlbum(
            identifier: assetCollection.localIdentifier,
            title: assetCollection.localizedTitle,
            fetchResult: PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        )
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
        observedAlbum?.fetchResult.enumerateObjects(using: { asset, _, _ in
            images.append(asset)
        })
        return images
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
    
    private func photoLibraryChanges(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> PhotoLibraryChanges
    {
        var assets = [PHAsset]()
        
        var insertedObjects = [(index: Int, item: PhotoLibraryItem)]()
        var insertedObjectIndex = changes.insertedObjects.count - 1
        
        var updatedObjects = [(index: Int, item: PhotoLibraryItem)]()
        var updatedObjectIndex = changes.changedObjects.count - 1
        
        var movedIndexes = [(from: Int, to: Int)]()
        
        changes.fetchResultBeforeChanges.enumerateObjects(using: { object, _, _ in
            assets.append(object)
        })
        
        changes.removedIndexes?.reversed().forEach { index in
            assets.remove(at: index)
        }
        
        changes.insertedIndexes?.reversed().forEach { index in
            guard insertedObjectIndex >= 0 else { return }
            let asset = changes.insertedObjects[insertedObjectIndex]
            insertedObjects.append((index: index, item: photoLibraryItem(from: asset)))
            insertedObjectIndex -= 1
        }
        
        changes.changedIndexes?.reversed().forEach { index in
            guard updatedObjectIndex >= 0 else { return }
            let asset = changes.changedObjects[updatedObjectIndex]
            updatedObjects.append((index: index, item: self.photoLibraryItem(from: asset)))
            updatedObjectIndex -= 1
        }
        
        changes.enumerateMoves { from, to in
            movedIndexes.append((from: from, to: to))
        }
        
        return PhotoLibraryChanges(
            removedIndexes: changes.removedIndexes ?? IndexSet(),
            insertedItems: insertedObjects,
            updatedItems: updatedObjects,
            movedIndexes: movedIndexes,
            itemsAfterChanges: photoLibraryItems(from: assets)
        )
    }
    
    private func allAlbums() -> [PhotoLibraryAlbum] {
        
        var albums = fetchResults.flatMap { $0.albums }
        
        // Search for the album with the largest number of photos, hoping that it's the "All Photos" album.
        let largestAlbum = albums.enumerated().max { album1, album2 in
            album1.element.numberOfItems < album2.element.numberOfItems
        }
        
        // "All Photos" album should be the first one.
        if let indexOfLargestAlbum = largestAlbum?.offset, indexOfLargestAlbum > 0 {
            albums.insert(albums.remove(at: indexOfLargestAlbum), at: 0)
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
    
    fileprivate var fetchResult: PHFetchResult<PHAsset>
    
    fileprivate init(
        identifier: String,
        title: String?,
        coverImage: ImageSource?,
        fetchResult: PHFetchResult<PHAsset>)
    {
        self.identifier = identifier
        self.title = title
        self.coverImage = coverImage
        self.fetchResult = fetchResult
        self.numberOfItems = fetchResult.count
    }
    
    func changingCoverImage(to image: ImageSource?) -> PhotoLibraryAlbum {
        return PhotoLibraryAlbum(
            identifier: identifier,
            title: title,
            coverImage: image,
            fetchResult: fetchResult
        )
    }
    
    static func ==(lhs: PhotoLibraryAlbum, rhs: PhotoLibraryAlbum) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
