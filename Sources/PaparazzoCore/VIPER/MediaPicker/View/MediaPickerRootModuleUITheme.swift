import UIKit

public protocol MediaPickerRootModuleUITheme: AccessDeniedViewTheme {
    
    var mediaPickerBackgroundColor: UIColor { get }
    var cameraControlsViewBackgroundColor: UIColor { get }
    var photoControlsViewBackgroundColor: UIColor { get }
    var thumbnailsViewBackgroundColor: UIColor { get }
    var photoPreviewBackgroundColor: UIColor { get }
    var photoPreviewCollectionBackgroundColor: UIColor { get }

    var mediaPickerTitleLightColor: UIColor { get }
    var mediaPickerTitleDarkColor: UIColor { get }

    var mediaPickerIconColor: UIColor { get }
    var mediaPickerIconActiveColor: UIColor { get }
    
    var buttonGrayHighlightedColor: UIColor { get }

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
    var cameraBottomContinueButtonHighlightedBackgroundColor: UIColor { get }
    var cameraBottomContinueButtonTitleColor: UIColor { get }
    var cameraBottomContinueButtonFont: UIFont { get }
    
    var removePhotoIcon: UIImage? { get }
    var autocorrectPhotoIcon: UIImage? { get }
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
