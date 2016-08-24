import UIKit
import AVFoundation

final class CameraView: UIView, CameraViewInput {
    
    private let accessDeniedView = AccessDeniedView()
    private var cameraOutputBinder: CameraOutputGLKBinder?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        accessDeniedView.hidden = true
        
        addSubview(accessDeniedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        accessDeniedView.frame = bounds
        cameraOutputBinder?.view.frame = bounds
    }
    
    // MARK: - CameraViewInput
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    func setAccessDeniedViewVisible(visible: Bool) {
        accessDeniedView.hidden = !visible
    }
    
    func setAccessDeniedTitle(title: String) {
        accessDeniedView.title = title
    }
    
    func setAccessDeniedMessage(message: String) {
        accessDeniedView.message = message
    }
    
    func setAccessDeniedButtonTitle(title: String) {
        accessDeniedView.buttonTitle = title
    }
    
    func setOutputParameters(parameters: CameraOutputParameters) {
        
        let cameraOutputBinder = CameraOutputGLKBinder(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation
        )
        
        let view = cameraOutputBinder.view
        view.clipsToBounds = true
        insertSubview(view, aboveSubview: accessDeniedView)
        
        self.cameraOutputBinder = cameraOutputBinder
    }
    
    func setOutputOrientation(orientation: ExifOrientation) {
        cameraOutputBinder?.orientation = orientation
    }
    
    // MARK: - CameraView
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {
        accessDeniedView.setTheme(theme)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}