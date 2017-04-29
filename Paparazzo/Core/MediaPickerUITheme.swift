import UIKit

public struct PaparazzoUITheme:
    MediaPickerRootModuleUITheme,
    PhotoLibraryUITheme,
    ImageCroppingUITheme,
    MaskCropperUITheme
{
    
    public init() {}

    // MARK: - MediaPickerRootModuleUITheme

    public var shutterButtonColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var shutterButtonDisabledColor = UIColor.lightGray
    public var mediaRibbonSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)

    public var removePhotoIcon = PaparazzoUITheme.image(named: "delete")
    public var cropPhotoIcon = PaparazzoUITheme.image(named: "crop")
    public var returnToCameraIcon = PaparazzoUITheme.image(named: "camera")
    public var closeCameraIcon = PaparazzoUITheme.image(named: "bt-close")
    public var flashOnIcon = PaparazzoUITheme.image(named: "light_on")
    public var flashOffIcon = PaparazzoUITheme.image(named: "light_off")
    public var cameraToggleIcon = PaparazzoUITheme.image(named: "back_front")
    public var photoPeepholePlaceholder = PaparazzoUITheme.image(named: "gallery-placeholder")

    public var cameraContinueButtonTitleFont = UIFont.systemFont(ofSize: 17)
    public var cameraContinueButtonTitleColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var cameraContinueButtonTitleHighlightedColor = UIColor(red: 0, green: 152.0/255, blue: 229.0/255, alpha: 1)
    public var cameraButtonsBackgroundNormalColor = UIColor.white
    public var cameraButtonsBackgroundHighlightedColor = UIColor(white: 1, alpha: 0.6)
    public var cameraButtonsBackgroundDisabledColor = UIColor(white: 1, alpha: 0.6)
    
    public var accessDeniedTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var accessDeniedMessageFont = UIFont.systemFont(ofSize: 17)
    public var accessDeniedButtonFont = UIFont.systemFont(ofSize: 17)

    // MARK: - PhotoLibraryUITheme
    
    public var photoLibraryDoneButtonFont = UIFont.boldSystemFont(ofSize: 17)
    
    public var photoLibraryItemSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var photoCellBackgroundColor = UIColor.RGB(red: 215, green: 215, blue: 215)
    
    public var iCloudIcon = PaparazzoUITheme.image(named: "icon-cloud")
    
    // MARK: - ImageCroppingUITheme
    
    public var rotationIcon = PaparazzoUITheme.image(named: "rotate")
    public var gridIcon = PaparazzoUITheme.image(named: "grid")
    public var gridSelectedIcon = PaparazzoUITheme.image(named: "grid")
    public var cropperDiscardIcon = PaparazzoUITheme.image(named: "discard")
    public var cropperConfirmIcon = PaparazzoUITheme.image(named: "confirm")
    public var cancelRotationButtonIcon = PaparazzoUITheme.image(named: "close-small")
    public var cancelRotationBackgroundColor = UIColor.RGB(red: 25, green: 25, blue: 25, alpha: 1)
    public var cancelRotationTitleColor = UIColor.white
    public var cancelRotationTitleFont = UIFont.boldSystemFont(ofSize: 14)
    
    // MARK: - MaskCropperUITheme
    
    public var maskCropperDiscardPhotoIcon = PaparazzoUITheme.image(named: "delete")
    public var maskCropperCloseButtonIcon = PaparazzoUITheme.image(named: "bt-close")
    
    public var maskCropperButtonsBackgroundNormalColor = UIColor.white
    public var maskCropperButtonsBackgroundHighlightedColor = UIColor(white: 1, alpha: 0.6)
    public var maskCropperButtonsBackgroundDisabledColor = UIColor(white: 1, alpha: 0.6)
    public var maskCropperConfirmButtonTitleColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var maskCropperConfirmButtonTitleHighlightedColor = UIColor(red: 0, green: 152.0/255, blue: 229.0/255, alpha: 1)
    
    public var maskCropperConfirmButtonTitleFont = UIFont.systemFont(ofSize: 17)

    // MARK: - Private

    private class BundleId {}

    private static func image(named name: String) -> UIImage? {
        let bundle = Bundle(for: BundleId.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
