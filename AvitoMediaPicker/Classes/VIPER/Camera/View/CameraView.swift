import UIKit
import AVFoundation

final class CameraView: UIView, CameraViewInput {
    
    private let accessDeniedView = AccessDeniedView()
    private var cameraOutputBinder: CameraOutputGLKBinder?
    private var outputParameters: CameraOutputParameters?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        accessDeniedView.isHidden = true
        
        addSubview(accessDeniedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        accessDeniedView.bounds = bounds
        accessDeniedView.center = bounds.center
        
        cameraOutputBinder?.view.frame = bounds
    }
    
    // MARK: - CameraViewInput
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    func setAccessDeniedViewVisible(_ visible: Bool) {
        accessDeniedView.isHidden = !visible
    }
    
    func setAccessDeniedTitle(_ title: String) {
        accessDeniedView.title = title
    }
    
    func setAccessDeniedMessage(_ message: String) {
        accessDeniedView.message = message
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        accessDeniedView.buttonTitle = title
    }
    
    func setOutputParameters(_ parameters: CameraOutputParameters) {
        
        let cameraOutputBinder = CameraOutputGLKBinder(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation
        )
        
        if let attachedBinder = self.cameraOutputBinder {
            // AI-3326: костыль для iOS 8.
            // Удаляем предыдущую вьюху, как только будет нарисован первый фрейм новой вьюхи, иначе будет мелькание.
            cameraOutputBinder.onFrameDrawn = { [weak cameraOutputBinder] in
                cameraOutputBinder?.onFrameDrawn = nil
                DispatchQueue.main.async {
                    attachedBinder.view.removeFromSuperview()
                }
            }
        }
        
        let view = cameraOutputBinder.view
        view.clipsToBounds = true
        addSubview(view)
        
        self.cameraOutputBinder = cameraOutputBinder
        self.outputParameters = parameters
    }
    
    func setOutputOrientation(_ orientation: ExifOrientation) {
        outputParameters?.orientation = orientation
        cameraOutputBinder?.orientation = orientation
    }
    
    func mainModuleDidAppear(animated: Bool) {
        // AI-3326: костыль для iOS 8.
        if let outputParameters = outputParameters {
            setOutputParameters(outputParameters)
        }
    }
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        UIView.animate(withDuration: 0.25) {
            self.accessDeniedView.transform = CGAffineTransform(deviceOrientation: orientation)
        }
    }
    
    // MARK: - CameraView
    
    func setTheme(_ theme: MediaPickerRootModuleUITheme) {
        accessDeniedView.setTheme(theme)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(_ object: AnyObject) {
        disposables.append(object)
    }
}
