import Photos
import ImageSource

final class PhotoLibraryAlbum {
    
    let identifier: String
    let title: String?
    let coverImage: ImageSource?
    
    fileprivate var fetchResult: PHFetchResult<PHAsset>
    
    fileprivate init(identifier: String, title: String?, coverImage: ImageSource?, fetchResult: PHFetchResult<PHAsset>) {
        self.identifier = identifier
        self.title = title
        self.coverImage = coverImage
        self.fetchResult = fetchResult
    }
}

protocol PhotoLibraryItemsService {
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(in: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryEvent) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.shared()
    
    private var albums = [PhotoLibraryAlbum]()
    private var albumsFetchResult: PHFetchResult<PHAssetCollection>?
    
    private let setupQueue = DispatchQueue(
        label: "ru.avito.Paparazzo.PhotoLibraryItemsServiceImpl.setupQueue",
        qos: .userInitiated
    )
    
    // lazy because if you create PHImageManager immediately
    // the app will crash on dealloc of this class if access to photo library is denied
    private lazy var imageManager = PHImageManager()
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        photoLibrary.register(self)
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
            handler(self.albums)
        }
    }
    
    func observeEvents(in album: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryEvent) -> ()) {
        executeAfterSetup {
            self.observedAlbum = album
            self.onEvent = handler
            self.callObserverHandler(changes: nil)
        }
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        executeAfterSetup {
            if let observedAlbum = self.observedAlbum,
               let changes = changeInfo.changeDetails(for: observedAlbum.fetchResult)
            {
                self.observedAlbum?.fetchResult = changes.fetchResultAfterChanges
                self.callObserverHandler(changes: changes)
            }
        }
    }

    // MARK: - Private
    
    private var onEvent: ((_ event: PhotoLibraryEvent) -> ())?
    private var onAlbumsChange: ((_ albums: [PhotoLibraryAlbum]) -> ())?
    private var onAuthorizationStatusChange: ((_ accessGranted: Bool) -> ())?
    
    private var observedAlbum: PhotoLibraryAlbum?
    private var wasSetUp = false
    
    private func executeAfterSetup(on queue: DispatchQueue = .main, execute: @escaping () -> ()) {
        setupQueue.async {
            self.setUpIfNeeded(completion: {
                queue.async(execute: execute)
            })
        }
    }
    
    private func setUpIfNeeded(completion: @escaping () -> ()) {
        
        guard !wasSetUp else {
            completion()
            return
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            wasSetUp = true
            setUpFetchRequest()
            completion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.wasSetUp = true
                if case .authorized = status {
                    self?.setUpFetchRequest()
                }
                completion()
                self?.callAuthorizationHandler(for: status)
            }
        case .restricted, .denied:
            wasSetUp = true
            completion()
        }
    }
    
    private func setUpFetchRequest() {
        
        let options = fetchOptions()
        
        var albumFetchRequests = [
            photoLibraryAlbum(
                identifier: "ru.avito.Paparazzo.PhotoLibraryAlbum.identifier.allPhotos",
                title: localized("All photos"),
                fetchResult: PHAsset.fetchAssets(with: .image, options: options)
            )
        ]
        
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        albums.enumerateObjects(using: { album, _, _ in
            albumFetchRequests.append(self.photoLibraryAlbum(
                identifier: album.localIdentifier,
                title: album.localizedTitle,
                fetchResult: PHAsset.fetchAssets(in: album, options: options)
            ))
        })
        
        self.albums = albumFetchRequests
        self.albumsFetchResult = albums
        
        callObserverHandler(changes: nil)
    }
    
    private func photoLibraryAlbum(identifier: String, title: String?, fetchResult: PHFetchResult<PHAsset>) -> PhotoLibraryAlbum {
        return PhotoLibraryAlbum(
            identifier: identifier,
            title: title,
            coverImage: fetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) },
            fetchResult: fetchResult
        )
    }
    
    private func fetchOptions() -> PHFetchOptions? {
        let options: PHFetchOptions?
        
        if #available(iOS 9.0, *) {
            options = PHFetchOptions()
            options?.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        } else {
            options = nil
        }
        
        return options
    }
    
    private func callAuthorizationHandler(for status: PHAuthorizationStatus) {
        onAuthorizationStatusChange?(status == .authorized)
    }

    private func callObserverHandler(changes phChanges: PHFetchResultChangeDetails<PHAsset>?) {
        if let phChanges = phChanges {
            onEvent?(.changes(photoLibraryChanges(from: phChanges)))
        } else {
            onEvent?(.initialLoad(photoLibraryItems(from: assetsFromFetchResult())))
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
}
