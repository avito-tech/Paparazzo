import AVFoundation

extension AVCaptureSession {
    
    func configure(configuration: () throws -> ()) throws {
        try beginConfiguration()
        try configuration()
        commitConfiguration()
    }
}
