import Photos

protocol PhotoLibraryItemsService {
    var authorizationStatus: PHAuthorizationStatus { get }
    func observePhotos(handler: [PHAsset] -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    private var receivedPhotoLibraryUpdates = false

    private(set) var fetchResult: PHFetchResult? {
        didSet {
            callObserverHandler()
        }
    }
    
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
    
    private var observerHandler: ([PHAsset] -> ())?
    
    var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    func observePhotos(handler: [PHAsset] -> ()) {
        observerHandler = handler
        callObserverHandler()
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(changeInfo: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            if let fetchResult = self.fetchResult, collectionChanges = changeInfo.changeDetailsForFetchResult(fetchResult) {
                self.fetchResult = collectionChanges.fetchResultAfterChanges
            }
        }
    }

    // MARK: - Private
    
    private func setUpFetchRequest() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }

    private func callObserverHandler() {
        observerHandler?(assetsFromFetchResult())
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