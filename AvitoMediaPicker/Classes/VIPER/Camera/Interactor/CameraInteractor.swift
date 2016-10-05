import AVFoundation

protocol CameraInteractor: class {
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ())
    func setCameraOutputNeeded(_: Bool)
    
    func isFlashAvailable(completion: (Bool) -> ())
    func isFlashEnabled(completion: @escaping (Bool) -> ())
    func setFlashEnabled(_: Bool, completion: @escaping (_ success: Bool) -> ())
    
    func canToggleCamera(completion: @escaping (Bool) -> ())
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ())
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ())
    
    func setPreviewImagesSizeForNewPhotos(_: CGSize)
}

struct CameraOutputParameters {
    let captureSession: AVCaptureSession
    var orientation: ExifOrientation
}
