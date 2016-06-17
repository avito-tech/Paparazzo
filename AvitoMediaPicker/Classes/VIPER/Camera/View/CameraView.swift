import UIKit
import AVFoundation

final class CameraView: UIView, CameraViewInput {
    
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraPreviewLayer?.frame = bounds
    }
    
    // MARK: - CameraViewInput
    
    func setCaptureSession(session: AVCaptureSession) {
        
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer.backgroundColor = UIColor.blackColor().CGColor
        cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.insertSublayer(cameraPreviewLayer, atIndex: 0)
        
        self.cameraPreviewLayer = cameraPreviewLayer
    }
    
    func setCameraUnavailableMessageVisible(visible: Bool) {
        // TODO
    }
    
    func adjustForDeviceOrientation(orientation: DeviceOrientation) {
        // TODO
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}