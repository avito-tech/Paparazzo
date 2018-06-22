import AVFoundation
import ImageSource

protocol CameraInteractor: class {
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ())
    func setCameraOutputNeeded(_: Bool)
    
    func isFlashAvailable(completion: (Bool) -> ())
    func isFlashEnabled(completion: @escaping (Bool) -> ())
    func setFlashEnabled(_: Bool, completion: ((_ success: Bool) -> ())?)
    
    func canToggleCamera(completion: @escaping (Bool) -> ())
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ())
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ())
    
    func setPreviewImagesSizeForNewPhotos(_: CGSize)
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    
    func focusCameraOnPoint(_: CGPoint) -> Bool
}

struct CameraOutputParameters {
    let captureSession: AVCaptureSession
    var orientation: ExifOrientation
    var isMetalEnabled: Bool
}
