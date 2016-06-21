import AVFoundation

protocol CameraInteractor: class {
    
    func getCaptureSession(completion: AVCaptureSession? -> ())
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ())
    
    func takePhoto(completion: MediaPickerItem? -> ())
    
    // Set nil handler to stop observing
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
}