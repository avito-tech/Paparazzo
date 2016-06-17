import Photos

protocol PhotoLibraryItemsService {
    func observePhotos(handler: [PHAsset] -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()

    private(set) var fetchResult: PHFetchResult {
        didSet {
            callObserverHandler()
        }
    }
    
    // MARK: - Init
    
    override init() {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        
        super.init()
        
        photoLibrary.registerChangeObserver(self)
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    private var observerHandler: ([PHAsset] -> ())?
    
    func observePhotos(handler: [PHAsset] -> ()) {
        observerHandler = handler
        callObserverHandler()
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(changeInfo: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            if let collectionChanges = changeInfo.changeDetailsForFetchResult(self.fetchResult) {
                self.fetchResult = collectionChanges.fetchResultAfterChanges
            }
        }
    }

    // MARK: - Private

    private func callObserverHandler() {
        observerHandler?(assetsFromFetchResult())
    }
    
    private func assetsFromFetchResult() -> [PHAsset] {
        
        var images = [PHAsset]()
        
        fetchResult.enumerateObjectsUsingBlock { asset, _, _ in
            if let asset = asset as? PHAsset {
                images.append(asset)
            }
        }
        
        return images
    }
}