public protocol MediaPickerRootModuleUITheme: AccessDeniedViewTheme {
    
    var shutterButtonColor: UIColor { get }
    var shutterButtonDisabledColor: UIColor { get }
    var mediaRibbonSelectionColor: UIColor { get }
    var cameraContinueButtonTitleColor: UIColor { get }
    var cameraContinueButtonTitleHighlightedColor: UIColor { get }
    var cameraButtonsBackgroundNormalColor: UIColor { get }
    var cameraButtonsBackgroundHighlightedColor: UIColor { get }
    var cameraButtonsBackgroundDisabledColor: UIColor { get }
    
    var removePhotoIcon: UIImage? { get }
    var cropPhotoIcon: UIImage? { get }
    var returnToCameraIcon: UIImage? { get }
    var closeCameraIcon: UIImage? { get }
    var flashOnIcon: UIImage? { get }
    var flashOffIcon: UIImage? { get }
    var cameraToggleIcon: UIImage? { get }
    var photoPeepholePlaceholder: UIImage? { get }
    
    var cameraContinueButtonTitleFont: UIFont { get }
}
