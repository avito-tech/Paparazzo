import ImageSource
import Photos
import UIKit

protocol PhotoLibraryLatestPhotoProvider {
    func observePhoto(handler: @escaping (ImageSource?) -> ())
}

final class PhotoLibraryLatestPhotoProviderImpl: NSObject, PhotoLibraryLatestPhotoProvider, PHPhotoLibraryChangeObserver {
    
    private let photoLibrary = PHPhotoLibrary.shared()
    private var isObservingPhotoLibraryChanges = false

    private let fetchResultQueue = DispatchQueue(
        label: "ru.avito.Paparazzo.PhotoLibraryLatestPhotoProviderImpl.fetchResultQueue",
        qos: .userInitiated
    )

    private(set) lazy var fetchResult = setUpInitialFetchResult() {
        didSet {
            callObserver()
        }
    }
    
    deinit {
        if isObservingPhotoLibraryChanges {
            photoLibrary.unregisterChangeObserver(self)
        }
    }
    
    // MARK: - PhotoLibraryLatestPhotoProvider
    
    private var photoObserverHandler: ((ImageSource?) -> ())?
    
    func observePhoto(handler: @escaping (ImageSource?) -> ()) {
        photoObserverHandler = handler
        callObserver()
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        fetchResultQueue.async {
            if let fetchResult = self.fetchResult, let collectionChanges = changeInfo.changeDetails(for: fetchResult) {
                self.fetchResult = collectionChanges.fetchResultAfterChanges
            }
        }
    }
    
    // MARK: - Private
    
    @discardableResult
    private func setUpInitialFetchResult() -> PHFetchResult<PHAsset>? {

        func setUpFetchResult() {
            fetchResultQueue.async { [weak self] in
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                options.fetchLimit = 1

                let fetchResult = PHAsset.fetchAssets(with: .image, options: options)

                if let strongSelf = self {
                    strongSelf.photoLibrary.register(strongSelf)
                    strongSelf.isObservingPhotoLibraryChanges = true
                }

                self?.fetchResult = fetchResult
            }
        }

        switch PHPhotoLibrary.readWriteAuthorizationStatus() {
        case .authorized:
            setUpFetchResult()
        #if compiler(>=5.3)
        // Xcode 12+
        case .limited:
            setUpFetchResult()
        #endif
        case .notDetermined:
            PHPhotoLibrary.requestReadWriteAuthorization { [weak self] status in
                self?.setUpInitialFetchResult()
            }
        case .restricted, .denied:
            break
        @unknown default:
            assertionFailure("Unknown authorization status")
        }
        
        return nil
    }
    
    private func callObserver() {
        let asset = fetchResult?.firstObject
        let image = asset.flatMap { PHAssetImageSource(asset: $0) }
        
        DispatchQueue.main.async { [photoObserverHandler] in
            photoObserverHandler?(image)
        }
    }
}
