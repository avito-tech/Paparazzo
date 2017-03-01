import Photos
import ImageSource

protocol PhotoLibraryItemsService {
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeItems(handler: @escaping (_ changes: PhotoLibraryChanges) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.shared()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    // lazy, т.к. нельзя сразу создавать PHImageManager,
    // иначе он крэшнется при деаллокации, если доступ к photo library запрещен
    private lazy var imageManager = PHImageManager()
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        photoLibrary.register(self)
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            setUpFetchRequest()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if case .authorized = status {
                    self?.setUpFetchRequest()
                }
                self?.callAuthorizationHandler(for: status)
            }
        case .restricted, .denied:
            break
        }
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        onAuthorizationStatusChange = handler
        callAuthorizationHandler(for: PHPhotoLibrary.authorizationStatus())
    }
    
    func observeItems(handler: @escaping (_ changes: PhotoLibraryChanges) -> ()) {
        onPhotosChange = handler
        callObserverHandler(changes: nil)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        DispatchQueue.main.async {
            if let fetchResult = self.fetchResult, let changes = changeInfo.changeDetails(for: fetchResult) {
                self.fetchResult = changes.fetchResultAfterChanges
                self.callObserverHandler(changes: changes)
            }
        }
    }

    // MARK: - Private
    
    private var onPhotosChange: ((_ changes: PhotoLibraryChanges) -> ())?
    private var onAuthorizationStatusChange: ((_ accessGranted: Bool) -> ())?
    
    private func setUpFetchRequest() {
        let options: PHFetchOptions?
        
        if #available(iOS 9.0, *) {
            options = PHFetchOptions()
            options?.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        } else {
            options = nil
        }
        
        fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        callObserverHandler(changes: nil)
    }
    
    private func callAuthorizationHandler(for status: PHAuthorizationStatus) {
        onAuthorizationStatusChange?(status == .authorized)
    }

    private func callObserverHandler(changes phChanges: PHFetchResultChangeDetails<PHAsset>?) {
        
        let changes: PhotoLibraryChanges
        
        if let phChanges = phChanges {
            changes = photoLibraryChanges(from: phChanges)
        
        } else {
        
            let items = photoLibraryItems(from: assetsFromFetchResult())
            
            changes = PhotoLibraryChanges(
                removedIndexes: IndexSet(),
                insertedItems: items.enumerated().map { (index: $0, item: $1) },
                updatedItems: [],
                movedIndexes: [],
                itemsAfterChanges: items
            )
        }
        
        onPhotosChange?(changes)
    }
    
    private func assetsFromFetchResult() -> [PHAsset] {
        var images = [PHAsset]()
        fetchResult?.enumerateObjects(using: { asset, _, _ in
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
        var assets = [PHAsset?]()
        
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
        
        let nonNilAssets = assets.flatMap {$0}
        assert(nonNilAssets.count == assets.count, "Objects other than PHAsset are not supported")
        
        return PhotoLibraryChanges(
            removedIndexes: changes.removedIndexes ?? IndexSet(),
            insertedItems: insertedObjects,
            updatedItems: updatedObjects,
            movedIndexes: movedIndexes,
            itemsAfterChanges: photoLibraryItems(from: nonNilAssets)
        )
    }
}
