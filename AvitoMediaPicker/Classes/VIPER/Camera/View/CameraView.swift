import UIKit
import AVFoundation

final class CameraView: UIView, CameraViewInput {
    
    private var cameraOutputBinder: CameraOutputGLKBinder?
    
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
        cameraOutputBinder?.view.frame = bounds
    }
    
    // MARK: - CameraViewInput
    
    func setOutputParameters(parameters: CameraOutputParameters) {
        
        let cameraOutputBinder = CameraOutputGLKBinder(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation
        )
        
        let view = cameraOutputBinder.view
        view.clipsToBounds = true
        insertSubview(view, atIndex: 0)
        
        self.cameraOutputBinder = cameraOutputBinder
    }
    
    func setOutputOrientation(orientation: ExifOrientation) {
        cameraOutputBinder?.orientation = orientation
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}