import AVFoundation

public protocol CameraStatusService: AnyObject {
    func cameraAuthorizationStatus(for type: AVMediaType) -> AVAuthorizationStatus
}
