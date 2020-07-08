import UIKit

public struct PaparazzoUITheme:
    MediaPickerRootModuleUITheme,
    PhotoLibraryUITheme,
    PhotoLibraryV2UITheme,
    ImageCroppingUITheme,
    MaskCropperUITheme,
    ScannerRootModuleUITheme,
    NewCameraUITheme
{
    public init() {}

    // MARK: - MediaPickerRootModuleUITheme

    public var mediaPickerBackgroundColor = UIColor.white
    public var cameraControlsViewBackgroundColor = UIColor.white
    public var photoControlsViewBackgroundColor = UIColor.white
    public var thumbnailsViewBackgroundColor = UIColor.white
    public var photoPreviewBackgroundColor = UIColor.white
    public var photoPreviewCollectionBackgroundColor = UIColor.white
    public var mediaPickerTitleLightColor = UIColor.white
    public var mediaPickerTitleDarkColor = UIColor.black

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
    public var cameraBottomContinueButtonBackgroundColor = UIColor(red: 0 / 255, green: 170.0 / 255, blue: 1, alpha: 1)
    public var cameraBottomContinueButtonTitleColor = UIColor.white
    public var cameraBottomContinueButtonFont = UIFont.systemFont(ofSize: 16)
    
    public var accessDeniedBackgroundColor = UIColor.white
    public var accessDeniedTitleColor = UIColor.black
    public var accessDeniedMessageColor = UIColor.black
    public var accessDeniedButtonTextColor = UIColor.white
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
    public var photoLibraryTitleColor = UIColor.black
    public var photoLibraryAlbumsDisclosureIconColor = UIColor.black
    
    public var photoLibraryAlbumsTableViewCellBackgroundColor = UIColor.white
    public var photoLibraryAlbumsTableViewBackgroundColor = UIColor.white
    public var photoLibraryAlbumsTableTopSeparatorColor = UIColor.RGB(red: 215, green: 215, blue: 215)
    public var photoLibraryAlbumsCellSelectedLabelColor = UIColor.RGB(red: 0, green: 170, blue: 255)
    public var photoLibraryAlbumsCellDefaultLabelColor = UIColor.RGB(red: 51, green: 51, blue: 51)
    public var photoLibraryCollectionBackgroundColor = UIColor.white
    
    // MARK: - PhotoLibraryV2UITheme
    public var continueButtonTitleColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var continueButtonTitleHighlightedColor = UIColor(red: 0, green: 152.0/255, blue: 229.0/255, alpha: 1)
    public var closeIcon = PaparazzoUITheme.image(named: "bt-close")
    public var continueButtonTitleFont = UIFont.systemFont(ofSize: 17)
    public var libraryBottomContinueButtonBackgroundColor = UIColor(red: 0 / 255, green: 170.0 / 255, blue: 1, alpha: 1)
    public var libraryBottomContinueButtonTitleColor = UIColor.white
    public var libraryBottomContinueButtonFont = UIFont.systemFont(ofSize: 16)
    public var librarySelectionIndexFont = UIFont.systemFont(ofSize: 16)
    public var libraryItemBadgeTextColor = UIColor.white
    public var libraryItemBadgeBackgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
    
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
    public var cameraIcon = PaparazzoUITheme.image(named: "camera-new")
    
    // MARK: - NewCameraUITheme
    public var newCameraCloseIcon = PaparazzoUITheme.image(named: "bt-close")
    public var newCameraFlashOnIcon = PaparazzoUITheme.image(named: "flash_on")
    public var newCameraFlashOffIcon = PaparazzoUITheme.image(named: "flash_off")
    public var newCameraDoneButtonFont = UIFont.systemFont(ofSize: 16)
    public var newCameraPhotosCountFont = UIFont.systemFont(ofSize: 16)
    public var newCameraPhotosCountColor = UIColor.black
    public var newCameraPhotosCountPlaceholderFont: UIFont = UIFont.systemFont(ofSize: 16)
    public var newCameraPhotosCountPlaceholderColor = UIColor(red: 0.646, green: 0.646, blue: 0.646, alpha: 1)
    public var newCameraHintFont = UIFont.systemFont(ofSize: 16)
    public var newCameraHintTextColor = UIColor.gray
    public var newCameraViewBackgroundColor = UIColor.white
    public var newCameraFlashBackgroundColor = UIColor.white
    public var newCameraButtonBackgroundColor = UIColor.white
    public var newCameraSelectedPhotosBarBackgroundColor = UIColor.white
    
    public var newCameraCaptureButtonBorderColorEnabled = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
    public var newCameraCaptureButtonBackgroundColorEnabled = UIColor.white
    public var newCameraCaptureButtonBorderColorDisabled = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    public var newCameraCaptureButtonBackgroundColorDisabled = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
    public var newCameraSelectedPhotosBarButtonTitleColorNormal = UIColor.white
    public var newCameraSelectedPhotosBarButtonBackgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)

    // MARK: - Private
    private static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: Resources.bundle, compatibleWith: nil)
    }
}
