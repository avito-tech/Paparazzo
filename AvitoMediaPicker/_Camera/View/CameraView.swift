import UIKit
import AVFoundation

final class CameraView: UIView {
    
    let cameraLayer: AVCaptureVideoPreviewLayer
    
    init(captureSession: AVCaptureSession) {
        cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        super.init(frame: .zero)
        layer.addSublayer(cameraLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraLayer.frame = bounds
    }
}
