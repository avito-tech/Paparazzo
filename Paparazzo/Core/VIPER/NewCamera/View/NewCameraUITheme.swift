import UIKit

public protocol NewCameraUITheme: AccessDeniedViewTheme {
    var newCameraCloseIcon: UIImage? { get }
    var newCameraFlashOnIcon: UIImage? { get }
    var newCameraFlashOffIcon: UIImage? { get }
    var newCameraDoneButtonFont: UIFont { get }
    var newCameraPhotosCountFont: UIFont { get }
    var newCameraPhotosCountColor: UIColor { get }
    var newCameraPhotosCountPlaceholderFont: UIFont { get }
    var newCameraPhotosCountPlaceholderColor: UIColor { get }
    var newCameraHintFont: UIFont { get }
    var newCameraHintTextColor: UIColor { get }
    var newCameraViewBackgroundColor: UIColor { get }
    var newCameraFlashBackgroundColor: UIColor { get }
    var newCameraSelectedPhotosBarBackgroundColor: UIColor { get }
    var newCameraSelectedPhotosBarButtonTitleColorNormal: UIColor { get }
    var newCameraSelectedPhotosBarButtonBackgroundColor: UIColor { get }
    var newCameraCaptureButtonBorderColorEnabled: UIColor { get }
    var newCameraCaptureButtonBackgroundColorEnabled: UIColor { get }
    var newCameraCaptureButtonBorderColorDisabled: UIColor { get }
    var newCameraCaptureButtonBackgroundColorDisabled: UIColor { get }
}
