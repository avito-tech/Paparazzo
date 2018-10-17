import UIKit

public struct PaparazzoUITheme:
    MediaPickerRootModuleUITheme,
    PhotoLibraryUITheme,
    PhotoLibraryV2UITheme,
    ImageCroppingUITheme,
    MaskCropperUITheme,
    ScannerRootModuleUITheme
{
    public init() {}

    // MARK: - MediaPickerRootModuleUITheme

    public var shutterButtonColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var shutterButtonDisabledColor = UIColor.lightGray
    public var mediaRibbonSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var focusIndicatorColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)

    public var removePhotoIcon = PaparazzoUITheme.image(named: "delete")
    public var autocorrectPhotoIconInactive = PaparazzoUITheme.image(named: "autocorrect_inactive")
    public var autocorrectPhotoIconActive = PaparazzoUITheme.image(named: "autocorrect_active")
    public var cropPhotoIcon = PaparazzoUITheme.image(named: "crop")
    public var returnToCameraIcon = PaparazzoUITheme.image(named: "camera")
    public var closeCameraIcon = PaparazzoUITheme.image(named: "bt-close")
    public var backIcon = PaparazzoUITheme.image(named: "bt-back")
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
    public var cameraTitleColor = UIColor(white: 1, alpha: 1)
    public var cameraTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var cameraSubtitleColor = UIColor(white: 1, alpha: 1)
    public var cameraSubtitleFont = UIFont.systemFont(ofSize: 14)
    public var cameraHintFont = UIFont.systemFont(ofSize: 17)
    
    public var accessDeniedTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var accessDeniedMessageFont = UIFont.systemFont(ofSize: 17)
    public var accessDeniedButtonFont = UIFont.systemFont(ofSize: 17)

    public var infoMessageFont = UIFont.systemFont(ofSize: 14)
    
    // MARK: - PhotoLibraryUITheme
    
    public var photoLibraryTitleFont = UIFont.boldSystemFont(ofSize: 18)
    public var photoLibraryAlbumsDisclosureIcon = PaparazzoUITheme.image(named: "arrow-down")
    
    public var photoLibraryItemSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var photoCellBackgroundColor = UIColor.RGB(red: 215, green: 215, blue: 215)
    
    public var iCloudIcon = PaparazzoUITheme.image(named: "icon-cloud")
    public var photoLibraryDiscardButtonIcon = PaparazzoUITheme.image(named: "discard")
    public var photoLibraryConfirmButtonIcon = PaparazzoUITheme.image(named: "confirm")
    public var photoLibraryAlbumCellFont = UIFont.systemFont(ofSize: 17)
    public var photoLibraryPlaceholderFont = UIFont.systemFont(ofSize: 17)
    public var photoLibraryPlaceholderColor = UIColor.gray
    
    // MARK: - PhotoLibraryV2UITheme
    public var continueButtonTitleColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var continueButtonTitleHighlightedColor = UIColor(red: 0, green: 152.0/255, blue: 229.0/255, alpha: 1)
    public var closeIcon = PaparazzoUITheme.image(named: "bt-close")
    public var continueButtonTitleFont = UIFont.systemFont(ofSize: 17)
    
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
    
    public var maskCropperDiscardPhotoIcon = PaparazzoUITheme.image(named: "discard")
    public var maskCropperConfirmPhotoIcon = PaparazzoUITheme.image(named: "confirm")
    public var cameraIcon = PaparazzoUITheme.image(named: "camera")

    // MARK: - Private
    private static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: Resources.bundle, compatibleWith: nil)
    }
}
