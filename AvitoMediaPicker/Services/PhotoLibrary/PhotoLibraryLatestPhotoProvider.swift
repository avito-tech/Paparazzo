import Photos
import UIKit

protocol PhotoLibraryLatestPhotoProvider {
    func observePhoto(handler: (AbstractImage? -> ())?)
}

final class PhotoLibraryLatestPhotoProviderImpl: NSObject, PhotoLibraryLatestPhotoProvider, PHPhotoLibraryChangeObserver {
    
    private let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    
    private(set) var fetchResult: PHFetchResult {
        didSet {
            callObserver()
        }
    }
    
    override init() {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1
        
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        
        super.init()
        
        photoLibrary.registerChangeObserver(self)
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryLatestPhotoProvider
    
    private var photoObserverHandler: (AbstractImage? -> ())?
    
    func observePhoto(handler: (AbstractImage? -> ())?) {
        photoObserverHandler = handler
        callObserver()
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
    
    private func callObserver() {
        let asset = fetchResult.firstObject as? PHAsset
        let image = asset.flatMap { PhotoLibraryAssetImage(asset: $0) }
        photoObserverHandler?(image)
    }
}