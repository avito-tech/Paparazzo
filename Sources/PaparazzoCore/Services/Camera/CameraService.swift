import AVFoundation
import ImageSource

public protocol CameraService: AnyObject {
    
    var isFlashAvailable: Bool { get }
    var isFlashEnabled: Bool { get }
    
    func getCaptureSession(completion: @escaping (AVCaptureSession?) -> ())
    func getOutputOrientation(completion: @escaping (ExifOrientation) -> ())
    
    // Returns a flag indicating whether changing flash mode was successful
    func setFlashEnabled(_: Bool) -> Bool
    
    func takePhoto(completion: @escaping (PhotoFromCamera?) -> ())
    func takePhotoToPhotoLibrary(croppedToRatio: CGFloat?, completion: @escaping (PhotoLibraryItem?) -> ())
    
    func setCaptureSessionRunning(_: Bool)
    
    func focusOnPoint(_ focusPoint: CGPoint) -> Bool
    
    func canToggleCamera(completion: @escaping (Bool) -> ())
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ())
}

public struct PhotoFromCamera {
    public let path: String
}
