import Photos

protocol PhotoLibraryItemsService {
    func observeAuthorizationStatus(handler: @escaping (PHAuthorizationStatus) -> ())
    func observePhotos(handler: @escaping (_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.shared()
    private var fetchResult: PHFetchResult<PHAsset>?
    
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
                self?.onAuthorizationStatusChange?(status)
            }
        case .restricted, .denied:
            break
        }
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    func observeAuthorizationStatus(handler: @escaping (PHAuthorizationStatus) -> ()) {
        onAuthorizationStatusChange = handler
        handler(PHPhotoLibrary.authorizationStatus())
    }
    
    func observePhotos(handler: @escaping (_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ()) {
        onPhotosChange = handler
        callObserverHandler(changes: nil)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        DispatchQueue.main.async {
            if let fetchResult = self.fetchResult, let changes = changeInfo.changeDetails(for: fetchResult) {
                debugPrint("photoLibraryDidChange")
                self.fetchResult = changes.fetchResultAfterChanges
                self.callObserverHandler(changes: changes)
            }
        }
    }

    // MARK: - Private
    
    private var onPhotosChange: ((_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ())?
    private var onAuthorizationStatusChange: ((PHAuthorizationStatus) -> ())?
    
    private func setUpFetchRequest() {
        
        // Сначала пытаемся найти альбом Camera Roll
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        fetchResult = albums.firstObject.flatMap { PHAsset.fetchAssets(in: $0, options: fetchOptions) }
        
        // Fallback на случай, если по какой-то причине не нашли альбом Camera Roll
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        
        callObserverHandler(changes: nil)
    }

    private func callObserverHandler(changes: PHFetchResultChangeDetails<PHAsset>?) {
        onPhotosChange?(assetsFromFetchResult(), changes)
    }
    
    private func assetsFromFetchResult() -> [PHAsset] {
        var images = [PHAsset]()
        fetchResult?.enumerateObjects(using: { asset, _, _ in
            images.append(asset)
        })
        return images
    }
}
