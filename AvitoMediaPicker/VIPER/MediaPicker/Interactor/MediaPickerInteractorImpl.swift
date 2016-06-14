import Foundation
import AVFoundation

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    private let imageResizingService: ImageResizingService
    
    private var deviceOrientationObserverHandler: (DeviceOrientation -> ())?
    
    init(
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider,
        imageResizingService: ImageResizingService
    ) {
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
        self.imageResizingService = imageResizingService
        
        deviceOrientationService.onOrientationChange = { [weak self] orientation in
            self?.deviceOrientationObserverHandler?(orientation)
        }
    }
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? {
        didSet {
            onCaptureSessionReady?(cameraService.captureSession)
        }
    }
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?) {
        deviceOrientationObserverHandler = handler
        handler?(deviceOrientationService.currentOrientation)
    }
    
    func observeLatestPhotoLibraryItem(handler: (LazyImage? -> ())?) {
        latestLibraryPhotoProvider.observePhoto(handler)
    }
    
    // MARK: - MediaPickerInteractor
    
    func isFlashAvailable(completion: Bool -> ()) {
        completion(cameraService.isFlashAvailable)
    }
    
    func setFlashEnabled(enabled: Bool) {
        cameraService.setFlashEnabled(enabled)
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        cameraService.takePhoto { [imageResizingService] photo in
            completion(photo.flatMap { photo in
                MediaPickerItem(image: CameraPhotoImage(
                    photo: photo,
                    imageResizingService: imageResizingService
                ))
            })
        }
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
}
