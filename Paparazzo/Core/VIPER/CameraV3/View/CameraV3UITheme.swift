import UIKit

public protocol CameraV3UITheme: AccessDeniedViewTheme {
    // Main
    var cameraV3ViewBackground: UIColor { get }
    var cameraV3CloseIcon: UIImage? { get }
    var cameraV3CloseIconColor: UIColor { get }
    var cameraV3FlashOnIcon: UIImage? { get }
    var cameraV3FlashOffIcon: UIImage? { get }
    var cameraV3FlashIconColor: UIColor { get }
    var cameraV3ToggleCameraIcon: UIImage? { get }
    var cameraV3ToggleCameraIconColor: UIColor { get }
    
    // HintView
    var cameraV3HintViewBackground: UIColor { get }
    var cameraV3HintViewFont: UIFont { get }
    var cameraV3HintViewFontColor: UIColor { get }
    
    // Shutter
    var cameraV3ShutterScaleFactor: CGFloat { get }
    var cameraV3ShutterEnabledColor: UIColor { get }
    var cameraV3ShutterDisabledColor: UIColor { get }
    
    // SelectedPhotos
    var cameraV3SelectedPhotosFont: UIFont { get }
    var cameraV3SelectedPhotosFontColor: UIColor { get }
    
    // Focus indicator
    var cameraV3BeforeAnimationStrokeColor: UIColor { get }
    var cameraV3AfterAnimationStrokeColor: UIColor { get }
    
    // Access denied always dark
    var cameraV3AccessDeniedBackgroundColor: UIColor { get }
    var cameraV3AccessDeniedTitleColor: UIColor { get }
    var cameraV3AccessDeniedMessageColor: UIColor { get }
    var cameraV3AccessDeniedButtonTextColor: UIColor { get }
    var cameraV3AccessDeniedTitleFont: UIFont { get }
    var cameraV3AccessDeniedMessageFont: UIFont { get }
    var cameraV3AccessDeniedButtonFont: UIFont { get }
}
