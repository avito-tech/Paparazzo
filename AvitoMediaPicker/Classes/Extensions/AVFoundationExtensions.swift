import AVFoundation

extension AVCaptureSession {
    
    func configure(@noescape configuration: () throws -> ()) throws {
        try beginConfiguration()
        try configuration()
        commitConfiguration()
    }
}