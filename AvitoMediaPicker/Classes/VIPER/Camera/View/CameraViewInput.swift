import AVFoundation

protocol CameraViewInput: class {
    
    func setCaptureSession(session: AVCaptureSession)
    func setCameraUnavailableMessageVisible(visible: Bool)
    
    func adjustForDeviceOrientation(orientation: DeviceOrientation)
}
