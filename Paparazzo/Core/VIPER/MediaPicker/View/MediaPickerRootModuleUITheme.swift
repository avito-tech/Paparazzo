import UIKit

public protocol MediaPickerRootModuleUITheme: AccessDeniedViewTheme {
    
    var shutterButtonColor: UIColor { get }
    var shutterButtonDisabledColor: UIColor { get }
    var focusIndicatorColor: UIColor { get }
    var mediaRibbonSelectionColor: UIColor { get }
    var cameraContinueButtonTitleColor: UIColor { get }
    var cameraContinueButtonTitleHighlightedColor: UIColor { get }
    var cameraButtonsBackgroundNormalColor: UIColor { get }
    var cameraButtonsBackgroundHighlightedColor: UIColor { get }
    var cameraButtonsBackgroundDisabledColor: UIColor { get }
    var cameraTitleColor: UIColor { get }
    var cameraTitleFont: UIFont { get }
    var cameraSubtitleColor: UIColor { get }
    var cameraSubtitleFont: UIFont { get }
    var cameraHintFont: UIFont { get }
    var cameraBottomContinueButtonBackgroundColor: UIColor { get }
    var cameraBottomContinueButtonTitleColor: UIColor { get }
    var cameraBottomContinueButtonFont: UIFont { get }
    
    var removePhotoIcon: UIImage? { get }
    var autocorrectPhotoIconInactive: UIImage? { get }
    var autocorrectPhotoIconActive: UIImage? { get }
    var cropPhotoIcon: UIImage? { get }
    var returnToCameraIcon: UIImage? { get }
    var closeCameraIcon: UIImage? { get }
    var backIcon: UIImage? { get }
    var flashOnIcon: UIImage? { get }
    var flashOffIcon: UIImage? { get }
    var cameraToggleIcon: UIImage? { get }
    var photoPeepholePlaceholder: UIImage? { get }
    
    var cameraContinueButtonTitleFont: UIFont { get }
    
    var infoMessageFont: UIFont { get }
}
