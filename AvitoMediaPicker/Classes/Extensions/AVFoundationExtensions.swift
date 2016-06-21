import AVFoundation

extension AVCaptureSession {
    
    func configure(configuration: () -> ()) throws {
        try beginConfiguration()
        configuration()
        commitConfiguration()
    }
}