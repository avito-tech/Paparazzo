import AVFoundation

protocol CameraService: class {
    
    // Will be nil after service initialization if back camera is not available
    var captureSession: AVCaptureSession? { get }
    
    var isFlashAvailable: Bool { get }
    
    // Returns a flag indicating whether changing flash mode was successful
    func setFlashEnabled(enabled: Bool) -> Bool
    
    func takePhoto(completion: PhotoFromCamera? -> ())
    func setCaptureSessionRunning(needsRunning: Bool)
    
    func switchToCamera(position: CameraPosition)
}

struct PhotoFromCamera {
    let url: NSURL
}

enum CameraPosition {
    case Front
    case Back
}