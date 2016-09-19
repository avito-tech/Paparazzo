import AVFoundation

extension AVCaptureSession {
    
    func configure(configuration: () throws -> ()) throws {
        beginConfiguration()
        try configuration()
        commitConfiguration()
    }
}
