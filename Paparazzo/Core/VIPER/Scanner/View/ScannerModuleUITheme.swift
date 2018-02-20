public protocol ScannerRootModuleUITheme: AccessDeniedViewTheme {
    
    var focusIndicatorColor: UIColor { get }
    var cameraTitleColor: UIColor { get }
    var cameraTitleFont: UIFont { get }
    var cameraSubtitleColor: UIColor { get }
    var cameraSubtitleFont: UIFont { get }
    
    var closeCameraIcon: UIImage? { get }
    
    var infoMessageFont: UIFont { get }
}
