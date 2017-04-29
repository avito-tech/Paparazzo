public protocol MaskCropperUITheme {
    var maskCropperDiscardPhotoIcon: UIImage? { get }
    var maskCropperCloseButtonIcon: UIImage? { get }
    
    var maskCropperButtonsBackgroundNormalColor: UIColor { get }
    var maskCropperButtonsBackgroundHighlightedColor: UIColor { get }
    var maskCropperButtonsBackgroundDisabledColor: UIColor { get }
    var maskCropperConfirmButtonTitleColor: UIColor { get }
    var maskCropperConfirmButtonTitleHighlightedColor: UIColor { get }
    
    var maskCropperConfirmButtonTitleFont: UIFont { get }
}
