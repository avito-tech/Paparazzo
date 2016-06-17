import AVFoundation

protocol CameraInteractor: class {
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? { get set }
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ())
    
    func takePhoto(completion: MediaPickerItem? -> ())
    
    // Set nil handler to stop observing
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
}