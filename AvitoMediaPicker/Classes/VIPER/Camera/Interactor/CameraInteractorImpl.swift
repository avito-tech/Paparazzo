import AVFoundation

final class CameraInteractorImpl: CameraInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    
    private var onDeviceOrientationChange: (DeviceOrientation -> ())?
    
    init(cameraService: CameraService, deviceOrientationService: DeviceOrientationService) {
        
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        
        deviceOrientationService.onOrientationChange = { [weak self] orientation in
            self?.onDeviceOrientationChange?(orientation)
        }
    }
    
    // MARK: - CameraInteractor
    
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
    
    func isFlashAvailable(completion: Bool -> ()) {
        completion(cameraService.isFlashAvailable)
    }
    
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ()) {
        completion(success: cameraService.setFlashEnabled(enabled))
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        cameraService.takePhoto { photo in
            completion(photo.flatMap { MediaPickerItem(image: UrlImageSource(url: $0.url)) })
        }
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
}
