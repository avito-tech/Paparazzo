import UIKit
import AVFoundation

final class CameraView: UIView, CameraViewInput {
    
    private let cameraOutputBinder = CameraOutputGLKBinder()
    private var cameraPreviewView: UIView?
    
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
        
        cameraPreviewView?.frame = bounds
    }
    
    // MARK: - CameraViewInput
    
    func setCaptureSession(session: AVCaptureSession) {

        let cameraPreviewView = cameraOutputBinder.setUpWithAVCaptureSession(session)
        cameraPreviewView.clipsToBounds = true

        insertSubview(cameraPreviewView, atIndex: 0)
        
        self.cameraPreviewView = cameraPreviewView
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