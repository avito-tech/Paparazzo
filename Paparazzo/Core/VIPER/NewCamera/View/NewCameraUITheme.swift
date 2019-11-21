import UIKit

public protocol NewCameraUITheme {
    var newCameraCloseIcon: UIImage? { get }
    var newCameraFlashOnIcon: UIImage? { get }
    var newCameraFlashOffIcon: UIImage? { get }
    var newCameraDoneButtonFont: UIFont { get }
    var newCameraPhotosCountFont: UIFont { get }
    var newCameraPhotosCountPlaceholderFont: UIFont { get }
    var newCameraHintFont: UIFont { get }
}
