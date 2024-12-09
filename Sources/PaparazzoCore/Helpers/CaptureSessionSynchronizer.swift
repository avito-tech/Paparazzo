import AVFoundation
import ImageSource

final class CaptureSessionSynchronizer {
    private weak var captureSession: AVCaptureSession?
    
    init(captureSession: AVCaptureSession) {
        self.captureSession = captureSession
    }

    var configuration: (() throws -> ())?
    
    private var timer: Timer?
    
    func startSynchronize() {
        dispatch_to_main_queue { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                guard let captureSession = self?.captureSession else { 
                    self?.invalidate() 
                    return 
                }
                
                if !captureSession.isRunning { return }
                
                captureSession.beginConfiguration()
                try? self?.configuration?()
                captureSession.commitConfiguration()
                self?.invalidate()
            } 
        }
    }
    
    func invalidate() {
        configuration = nil
        timer?.invalidate()
    }
}
