import Photos

protocol PhotoLibraryItemsService {
    func observePhotos(handler: [LazyImage] -> ())
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
    
    private var observerHandler: ([LazyImage] -> ())?
    
    func observePhotos(handler: [LazyImage] -> ()) {
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
        observerHandler?(imagesFromFetchResult())
    }
    
    private func imagesFromFetchResult() -> [LazyImage] {
        
        var images = [LazyImage]()
        
        fetchResult.enumerateObjectsUsingBlock { asset, index, stop in
            if let asset = asset as? PHAsset {
                images.append(PhotoLibraryAssetImage(asset: asset))
            }
        }
        
        return images
    }
}