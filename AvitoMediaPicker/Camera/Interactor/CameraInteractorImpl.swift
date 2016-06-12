import Foundation
import AVFoundation

final class CameraInteractorImpl: CameraInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    
    private var deviceOrientationObserverHandler: (DeviceOrientation -> ())?
    
    init(
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
        
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
    
    func takePhoto(completion: CameraPhoto? -> ()) {
        cameraService.takePhoto(completion)
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
}
