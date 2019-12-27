import UIKit

public protocol NewCameraUITheme: AccessDeniedViewTheme {
    var newCameraCloseIcon: UIImage? { get }
    var newCameraFlashOnIcon: UIImage? { get }
    var newCameraFlashOffIcon: UIImage? { get }
    var newCameraDoneButtonFont: UIFont { get }
    var newCameraPhotosCountFont: UIFont { get }
    var newCameraPhotosCountPlaceholderFont: UIFont { get }
    var newCameraHintFont: UIFont { get }
    var newCameraViewBackgroundColor: UIColor { get }
    var newCameraFlashBackgroundColor: UIColor { get }
    var newCameraSelectedPhotosBarBackgroundColor: UIColor { get }
    var newCameraCaptureButtonBorderColorEnabled: UIColor { get }
    var newCameraCaptureButtonBackgroundColorEnabled: UIColor { get }
    var newCameraCaptureButtonBorderColorDisabled: UIColor { get }
    var newCameraCaptureButtonBackgroundColorDisabled: UIColor { get }
}
