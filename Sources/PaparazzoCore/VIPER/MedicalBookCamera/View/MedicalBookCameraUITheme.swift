import UIKit

public protocol MedicalBookCameraUITheme: AccessDeniedViewTheme {
    var medicalBookViewBackground: UIColor { get }

    var medicalBookCloseIcon: UIImage? { get }
    var medicalBookCloseIconColor: UIColor { get }
    var medicalBookFlashOnIcon: UIImage? { get }
    var medicalBookFlashOffIcon: UIImage? { get }
    var medicalBookFlashIconColor: UIColor { get }
    var medicalBookToggleCameraIcon: UIImage? { get }
    var medicalBookToggleCameraIconColor: UIColor { get }

    var medicalBookHintViewBackground: UIColor { get }
    var medicalBookHintViewFont: UIFont { get }
    var medicalBookHintViewFontColor: UIColor { get }

    var medicalBookShutterScaleFactor: CGFloat { get }
    var medicalBookShutterEnabledColor: UIColor { get }
    var medicalBookShutterDisabledColor: UIColor { get }

    var medicalBookSelectedPhotosFont: UIFont { get }
    var medicalBookSelectedPhotosFontColor: UIColor { get }
    
    var medicalBookAccessDeniedBackgroundColor: UIColor { get }
    var medicalBookAccessDeniedTitleColor: UIColor { get }
    var medicalBookAccessDeniedMessageColor: UIColor { get }
    var medicalBookAccessDeniedButtonTextColor: UIColor { get }
    var medicalBookAccessDeniedTitleFont: UIFont { get }
    var medicalBookAccessDeniedMessageFont: UIFont { get }
    var medicalBookAccessDeniedButtonFont: UIFont { get }
}
