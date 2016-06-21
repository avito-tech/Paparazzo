import UIKit

public struct MediaPickerUITheme: MediaPickerRootModuleUITheme, PhotoLibraryUITheme {

    public init() {}

    // MARK: - MediaPickerRootModuleUITheme

    public var shutterButtonColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var mediaRibbonSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var cameraContinueButtonTitleColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)

    public var removePhotoIcon: UIImage? { return imageNamed("delete") }
    public var cropPhotoIcon: UIImage? { return imageNamed("crop") }
    public var returnToCameraIcon: UIImage? { return imageNamed("camera") }
    public var closeCameraIcon: UIImage? { return imageNamed("bt-close") }
    public var flashOnIcon: UIImage? { return imageNamed("light_on") }
    public var flashOffIcon: UIImage? { return imageNamed("light_off") }
    public var cameraToggleIcon: UIImage? { return imageNamed("back_front") }

    public var cameraContinueButtonTitleFont: UIFont { return UIFont.systemFontOfSize(17) }

    // MARK: - PhotoLibraryUITheme
    
    public var photoLibraryItemSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)

    // MARK: - Private

    private class BundleId {}

    private func imageNamed(name: String) -> UIImage? {
        let bundle = NSBundle(forClass: BundleId.self)
        return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
    }
}

public protocol MediaPickerRootModuleUITheme {

    var shutterButtonColor: UIColor { get }
    var mediaRibbonSelectionColor: UIColor { get }
    var cameraContinueButtonTitleColor: UIColor { get }

    var removePhotoIcon: UIImage? { get }
    var cropPhotoIcon: UIImage? { get }
    var returnToCameraIcon: UIImage? { get }
    var closeCameraIcon: UIImage? { get }
    var flashOnIcon: UIImage? { get }
    var flashOffIcon: UIImage? { get }
    var cameraToggleIcon: UIImage? { get }

    var cameraContinueButtonTitleFont: UIFont { get }
}

public protocol PhotoLibraryUITheme {
    var photoLibraryItemSelectionColor: UIColor { get }
}