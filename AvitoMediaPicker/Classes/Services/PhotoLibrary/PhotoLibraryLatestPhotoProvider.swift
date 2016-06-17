import Photos
import UIKit

protocol PhotoLibraryLatestPhotoProvider {
    func observePhoto(handler: (ImageSource? -> ())?)
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
        
        if #available(iOS 9.0, *) {
            options.fetchLimit = 1
        }
        
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        
        super.init()
        
        photoLibrary.registerChangeObserver(self)
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryLatestPhotoProvider
    
    private var photoObserverHandler: (ImageSource? -> ())?
    
    func observePhoto(handler: (ImageSource? -> ())?) {
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
        let image = asset.flatMap { PHAssetImageSource(asset: $0) }
        photoObserverHandler?(image)
    }
}