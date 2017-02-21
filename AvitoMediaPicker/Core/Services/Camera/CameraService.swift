import AVFoundation
import ImageSource

protocol CameraService: class {
    
    var isFlashAvailable: Bool { get }
    var isFlashEnabled: Bool { get }
    
    func getCaptureSession(completion: @escaping (AVCaptureSession?) -> ())
    func getOutputOrientation(completion: @escaping (ExifOrientation) -> ())
    
    // Returns a flag indicating whether changing flash mode was successful
    func setFlashEnabled(_: Bool) -> Bool
    
    func takePhoto(completion: @escaping (PhotoFromCamera?) -> ())
    func setCaptureSessionRunning(_: Bool)
    
    func canToggleCamera(completion: @escaping (Bool) -> ())
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ())
}

struct PhotoFromCamera {
    let path: String
}
