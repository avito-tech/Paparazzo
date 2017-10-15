import Photos
import ImageSource

protocol PhotoLibraryItemsService {
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(in: PhotoLibraryAlbum, handler: @escaping (_ event: PhotoLibraryEvent) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {
    
    private let photoLibrary = PHPhotoLibrary.shared()
    private var albumsFetchResult: PhotoLibraryFetchResult?
    
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
            handler(self.albumsFetchResult?.albums ?? [])
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
            
            if let albumsFetchResult = self.albumsFetchResult,
               let changes = changeInfo.changeDetails(for: albumsFetchResult.phFetchResult)
            {
                PhotoLibraryFetchResult.create(with: { changes.fetchResultAfterChanges }) { albumsFetchResult in
                    self.albumsFetchResult = albumsFetchResult
                    self.onAlbumsChange?(albumsFetchResult.albums)
                }
            }
            
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
                self?.callAuthorizationHandler(for: status)
                self?.wasSetUp = true
                
                if case .authorized = status {
                    self?.setUpFetchResult(completion: completion)
                } else {
                    completion()
                }
            }
            
        case .restricted, .denied:
            wasSetUp = true
            completion()
        }
    }
    
    private func setUpFetchResult(completion: @escaping () -> ()) {
        PhotoLibraryFetchResult.create { albumsFetchResult in
            self.albumsFetchResult = albumsFetchResult
            self.callObserverHandler(changes: nil)
            completion()
        }
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

private final class PhotoLibraryFetchResult {
    
    // MARK: - Data
    let albums: [PhotoLibraryAlbum]
    let phFetchResult: PHFetchResult<PHAssetCollection>
    
    private static let setupQueue = DispatchQueue(
        label: "ru.avito.Paparazzo.PhotoLibraryFetchResult.setupQueue",
        qos: .userInitiated
    )
    
    // MARK: - Init
    
    /// Use `PhotoLibraryFetchResult.create` to create an instance
    private init(phFetchResult: PHFetchResult<PHAssetCollection>?) {
        assert(!Thread.isMainThread, "Do not call this method on main thread")
        
        let options = PhotoLibraryFetchResult.phFetchOptions()
        
        self.phFetchResult = phFetchResult ?? PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: options
        )
        
        self.albums = PhotoLibraryFetchResult.albums(from: self.phFetchResult, options: options)
    }
    
    // MARK: - Private
    
    static func create(
        with phFetchResult: (() -> PHFetchResult<PHAssetCollection>)? = nil,
        completion: @escaping (PhotoLibraryFetchResult) -> ())
    {
        setupQueue.async {
            let fetchResult = PhotoLibraryFetchResult(phFetchResult: phFetchResult?())
            DispatchQueue.main.async {
                completion(fetchResult)
            }
        }
    }
    
    private static func albums(
        from phFetchResult: PHFetchResult<PHAssetCollection>,
        options: PHFetchOptions?)
        -> [PhotoLibraryAlbum]
    {
        assert(!Thread.isMainThread, "Do not call this method on main thread")
        
        let allPhotosStartDate = Date()
        let allPhotosFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        print("All photos fetch took \(Date().timeIntervalSince(allPhotosStartDate))")
        
        var albums = [
            PhotoLibraryAlbum(
                identifier: "ru.avito.Paparazzo.PhotoLibraryAlbum.identifier.allPhotos",
                title: localized("All photos"),
                coverImage: allPhotosFetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) },
                fetchResult: allPhotosFetchResult
            )
        ]
        
        phFetchResult.enumerateObjects(using: { album, _, _ in
            
            let startDate = Date()
            let albumAssetsFetchResult = PHAsset.fetchAssets(in: album, options: options)
            print("\(album.localizedTitle) fetch took \(Date().timeIntervalSince(startDate))")
            
            albums.append(PhotoLibraryAlbum(
                identifier: album.localIdentifier,
                title: album.localizedTitle,
                coverImage: albumAssetsFetchResult.lastObject.flatMap { PHAssetImageSource(asset: $0) },
                fetchResult: albumAssetsFetchResult
            ))
        })
        
        return albums
    }
    
    private static func phFetchOptions() -> PHFetchOptions? {
        if #available(iOS 9.0, *) {
            let options = PHFetchOptions()
            options.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
            return options
        } else {
            return nil
        }
    }
}

final class PhotoLibraryAlbum: Equatable {
    
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
    
    static func ==(lhs: PhotoLibraryAlbum, rhs: PhotoLibraryAlbum) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
