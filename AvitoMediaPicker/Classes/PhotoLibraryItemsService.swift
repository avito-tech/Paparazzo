import Photos

protocol PhotoLibraryItemsService {
    var authorizationStatus: PHAuthorizationStatus { get }
    func observePhotos(handler: (assets: [PHAsset], changes: PHFetchResultChangeDetails?) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    private var fetchResult: PHFetchResult?
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        photoLibrary.registerChangeObserver(self)
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .Authorized:
            setUpFetchRequest()
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if case .Authorized = status {
                    self?.setUpFetchRequest()
                }
            }
        case .Restricted, .Denied:
            break
        }
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    private var observerHandler: ((assets: [PHAsset], changes: PHFetchResultChangeDetails?) -> ())?
    
    var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    func observePhotos(handler: (assets: [PHAsset], changes: PHFetchResultChangeDetails?) -> ()) {
        observerHandler = handler
        callObserverHandler(changes: nil)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(changeInfo: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            if let fetchResult = self.fetchResult, changes = changeInfo.changeDetailsForFetchResult(fetchResult) {
                debugPrint("photoLibraryDidChange")
                self.fetchResult = changes.fetchResultAfterChanges
                self.callObserverHandler(changes: changes)
            }
        }
    }

    // MARK: - Private
    
    private func setUpFetchRequest() {
        let options = PHFetchOptions()
        
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        callObserverHandler(changes: nil)
    }

    private func callObserverHandler(changes changes: PHFetchResultChangeDetails?) {
        observerHandler?(assets: assetsFromFetchResult(), changes: changes)
    }
    
    private func assetsFromFetchResult() -> [PHAsset] {
        
        var images = [PHAsset]()
        
        fetchResult?.enumerateObjectsUsingBlock { asset, _, _ in
            if let asset = asset as? PHAsset {
                images.append(asset)
            }
        }
        
        return images
    }
}