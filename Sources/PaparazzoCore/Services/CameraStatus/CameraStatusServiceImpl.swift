import AVFoundation

public final class CameraStatusServiceImpl: CameraStatusService {
    
    public init() {}
    
    // MARK: - CameraStatusService
    public func cameraAuthorizationStatus(for type: AVMediaType) -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: type)
    }
}
