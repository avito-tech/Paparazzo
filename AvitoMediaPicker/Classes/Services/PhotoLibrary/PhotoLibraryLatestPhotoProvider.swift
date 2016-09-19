import Photos
import UIKit

protocol PhotoLibraryLatestPhotoProvider {
    func observePhoto(handler: @escaping (ImageSource?) -> ())
}

final class PhotoLibraryLatestPhotoProviderImpl: NSObject, PhotoLibraryLatestPhotoProvider, PHPhotoLibraryChangeObserver {
    
    private let photoLibrary = PHPhotoLibrary.shared()
    
    private(set) var fetchResult: PHFetchResult<PHAsset> {
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
        
        fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        super.init()
        
        photoLibrary.register(self)
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryLatestPhotoProvider
    
    private var photoObserverHandler: ((ImageSource?) -> ())?
    
    func observePhoto(handler: @escaping (ImageSource?) -> ()) {
        photoObserverHandler = handler
        callObserver()
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        DispatchQueue.main.async {
            if let collectionChanges = changeInfo.changeDetails(for: self.fetchResult) {
                self.fetchResult = collectionChanges.fetchResultAfterChanges
            }
        }
    }
    
    // MARK: - Private
    
    private func callObserver() {
        let asset = fetchResult.firstObject
        let image = asset.flatMap { PHAssetImageSource(asset: $0) }
        photoObserverHandler?(image)
    }
}
