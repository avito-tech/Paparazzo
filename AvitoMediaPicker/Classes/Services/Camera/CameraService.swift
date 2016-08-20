import AVFoundation

protocol CameraService: class {
    
    var isFlashAvailable: Bool { get }
    
    func getCaptureSession(completion: AVCaptureSession? -> ())
    func getOutputOrientation(completion: ExifOrientation -> ())
    
    // Returns a flag indicating whether changing flash mode was successful
    func setFlashEnabled(enabled: Bool) -> Bool
    
    func takePhoto(completion: PhotoFromCamera? -> ())
    func setCaptureSessionRunning(needsRunning: Bool)
    
    func canToggleCamera(completion: Bool -> ())
    func toggleCamera(completion: (newOutputOrientation: ExifOrientation) -> ())
}

struct PhotoFromCamera {
    let url: NSURL
}