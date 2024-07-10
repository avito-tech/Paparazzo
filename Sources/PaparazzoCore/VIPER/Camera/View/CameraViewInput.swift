import ImageSource
import CoreGraphics

protocol CameraViewInput: AnyObject {
    
    func setTitle(_: String?)
    func setSubtitle(_: String?)
    func setOutputParameters(_: CameraOutputParameters)
    func setOutputOrientation(_: ExifOrientation)
    
    func setCameraHintVisible(_:Bool)
    func setCameraHint(text: String)
    
    // MARK: - Focus
    var onFocusTap: ((_ focusPoint: CGPoint, _ touchPoint: CGPoint) -> Void)? { get set }
    func displayFocus(onPoint: CGPoint)
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    // MARK: - Callbacks from main module
    func mainModuleDidAppear(animated: Bool)
    func adjustForDeviceOrientation(_: DeviceOrientation)
}
