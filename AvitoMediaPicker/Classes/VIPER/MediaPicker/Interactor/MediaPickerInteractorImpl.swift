import Foundation
import AVFoundation

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let maxItemsCount: Int?
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    
    private var items = [MediaPickerItem]()

    private var onDeviceOrientationChange: (DeviceOrientation -> ())?
    
    init(
        maxItemsCount: Int?,
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.maxItemsCount = maxItemsCount
        
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider

        deviceOrientationService.onOrientationChange = { [weak self] orientation in
            self?.onDeviceOrientationChange?(orientation)
        }
    }

    // MARK: - MediaPickerInteractor
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? {
        didSet {
            if let captureSession = cameraService.captureSession {
                onCaptureSessionReady?(captureSession)
            }
        }
    }
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?) {
        onDeviceOrientationChange = handler
        handler?(deviceOrientationService.currentOrientation)
    }
    
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?) {
        latestLibraryPhotoProvider.observePhoto(handler)
    }
    
    func isFlashAvailable(completion: Bool -> ()) {
        completion(cameraService.isFlashAvailable)
    }
    
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ()) {
        completion(success: cameraService.setFlashEnabled(enabled))
    }
    
    func takePhoto(completion: (item: MediaPickerItem?, canTakeMorePhotos: Bool) -> ()) {
        cameraService.takePhoto { photo in
            let item = photo.flatMap { MediaPickerItem(image: UrlImageSource(url: $0.url)) }
            completion(item: item, canTakeMorePhotos: true)   // TODO: canTakeMorePhotos
        }
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
    
    func addPhotoLibraryItems(items: [AnyObject], completion: ()) {
        // TODO
    }
    
    func removeItem(item: MediaPickerItem) {
        // TODO
    }
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ()) {
        completion(maxItemsCount.flatMap { $0 - items.count })
    }
}
