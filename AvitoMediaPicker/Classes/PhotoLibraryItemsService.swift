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
                self.fetchResult = changes.fetchResultAfterChanges
                self.callObserverHandler(changes: changes)
            }
        }
    }

    // MARK: - Private
    
    private var onPhotosChange: ((_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ())?
    private var onAuthorizationStatusChange: ((PHAuthorizationStatus) -> ())?
    
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
