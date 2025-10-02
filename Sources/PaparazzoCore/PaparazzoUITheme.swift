import UIKit

public struct PaparazzoUITheme:
    MediaPickerRootModuleUITheme,
    PhotoLibraryUITheme,
    PhotoLibraryV2UITheme,
    PhotoLibraryV3UITheme,
    ImageCroppingUITheme,
    MaskCropperUITheme,
    ScannerRootModuleUITheme,
    NewCameraUITheme,
    CameraV3UITheme,
    MedicalBookCameraUITheme
{
    public init() {}

    // MARK: - MediaPickerRootModuleUITheme

    public var mediaPickerBackgroundColor = UIColor.white
    public var cameraControlsViewBackgroundColor = UIColor.white
    public var photoControlsViewBackgroundColor = UIColor.white
    public var thumbnailsViewBackgroundColor = UIColor.white
    public var photoPreviewBackgroundColor = UIColor.white
    public var photoPreviewCollectionBackgroundColor = UIColor.white
    public var mediaPickerTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var mediaPickerTitleLightColor = UIColor.white
    public var mediaPickerTitleDarkColor = UIColor.black
    public var mediaPickerIconColor = UIColor.black
    public var mediaPickerIconActiveColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var mediaPickerIconDisableColor: UIColor? = UIColor(red: 244.0/255, green: 244.0/255, blue: 244.0/255, alpha: 1)
    public var mediaPickerDoneButtonColor = UIColor.black
    public var mediaPickerDoneButtonHighlightedColor = UIColor.black
    public var buttonGrayHighlightedColor = UIColor(red: 227.0/255, green: 226.0/255, blue: 225.0/255, alpha: 1)

    public var shutterButtonColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var shutterButtonDisabledColor = UIColor.lightGray
    public var newMediaRibbonSelectionColor = UIColor(red: 20.0/255, green: 20.0/255, blue: 20.0/255, alpha: 1)
    public var legacyMediaRibbonSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var focusIndicatorColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)

    public var removePhotoIcon = PaparazzoUITheme.image(named: "delete")
    public var autocorrectPhotoIcon = PaparazzoUITheme.image(named: "autocorrect")
    public var cropPhotoIcon = PaparazzoUITheme.image(named: "crop")
    public var autoEnhanceImageIcon = PaparazzoUITheme.image(named: "autoEnhanceImage")
    public var returnToCameraIcon = PaparazzoUITheme.image(named: "camera")
    public var closeCameraIcon = PaparazzoUITheme.image(named: "bt-close")
    public var backIconRedesigned = PaparazzoUITheme.image(named: "bt-back-redesigned")
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
    public var cameraBottomContinueButtonHighlightedBackgroundColor = UIColor(red: 0 / 255, green: 153.0 / 255, blue: 247.0/255, alpha: 1)
    public var cameraBottomContinueButtonTitleColor = UIColor.white
    public var cameraBottomContinueButtonFont = UIFont.systemFont(ofSize: 16)
    
    public var accessDeniedBackgroundColor = UIColor.white
    public var accessDeniedTitleColor = UIColor.black
    public var accessDeniedMessageColor = UIColor.black
    public var accessDeniedButtonTextColor = UIColor.white
    public var accessDeniedTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var accessDeniedMessageFont = UIFont.systemFont(ofSize: 17)
    public var accessDeniedButtonFont = UIFont.systemFont(ofSize: 17)
    public var accessDeniedButtonBackgroundColor: UIColor = UIColor.RGB(red: 0, green: 170, blue: 255, alpha: 1)
    public var accessDeniedButtonCornerRadius: CGFloat = 4

    public var infoMessageFont = UIFont.systemFont(ofSize: 14)
    
    public var imagePerceptionBadgeTextColor = UIColor.white
    public var imagePerceptionBadgeTextFont = UIFont.systemFont(ofSize: 11)
    
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
    
    // MARK: - PhotoLibraryV2UITheme & PhotoLibraryV3UITheme
    public var continueButtonTitleColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var continueButtonTitleHighlightedColor = UIColor(red: 0, green: 152.0/255, blue: 229.0/255, alpha: 1)
    public var closeIcon = PaparazzoUITheme.image(named: "bt-close")
    public var closeIconColor = UIColor.black
    public var continueButtonTitleFont = UIFont.systemFont(ofSize: 17)
    public var libraryBottomContinueButtonBackgroundColor = UIColor(red: 0 / 255, green: 170.0 / 255, blue: 1, alpha: 1)
    public var libraryBottomContinueButtonTitleColor = UIColor.white
    public var libraryBottomContinueButtonFont = UIFont.systemFont(ofSize: 16)
    public var librarySelectionIndexFont = UIFont.systemFont(ofSize: 16)
    public var libraryItemBadgeTextColor = UIColor.white
    public var libraryItemBadgeBackgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
    public var cameraIcon = PaparazzoUITheme.image(named: "camera-new")
    public var cameraIconColor = UIColor.white
    
    // MARK: PhotoLibraryV3UITheme
    public var progressIndicatorColor = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
    public var libraryBottomContinueButtonCornerRadius: CGFloat = 5
    public var libraryItemBadgeCornerRadius: CGFloat = 10
    public var cameraCornerRadius: CGFloat = 28
    public var photoLibraryAlbumsCellImageCornerRadius: CGFloat = 12
    public var libraryItemImageOverlayColor: UIColor = UIColor.clear
    
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
    
    // MARK: - NewCameraUITheme
    public var newCameraCloseIcon = PaparazzoUITheme.image(named: "bt-close")
    public var newCameraFlashOnIcon = PaparazzoUITheme.image(named: "flash_on")
    public var newCameraFlashOffIcon = PaparazzoUITheme.image(named: "flash_off")
    public var newCameraToggleCameraIcon = PaparazzoUITheme.image(named: "back_front_new")
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
    public var newCameraSelectedPhotosBarButtonCornerRadius: CGFloat = 12
    public var newCameraSelectedPhotosBarPhotoCornerRadius: CGFloat = 10
    public var newCameraSelectedPhotosBarPhotoOverlayColor: UIColor = UIColor.clear
    public var newCameraSelectedPhotosBarCornerRadius: CGFloat = 28
    public var newCameraCaptureButtonBorderColorEnabled = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
    public var newCameraCaptureButtonBackgroundColorEnabled = UIColor.white
    public var newCameraCaptureButtonBorderColorDisabled = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    public var newCameraCaptureButtonBackgroundColorDisabled = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
    public var newCameraSelectedPhotosBarButtonTitleColorNormal = UIColor.white
    public var newCameraSelectedPhotosBarButtonBackgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
    public var newCameraButtonTintColor = UIColor.black
    
    // MARK: - CameraV3Theme

    public var cameraV3ViewBackground = UIColor.black
    public var cameraV3CloseIcon = PaparazzoUITheme.image(named: "bt-close")
    public var cameraV3CloseIconColor = UIColor.white
    public var cameraV3FlashOnIcon = PaparazzoUITheme.image(named: "flash_on")
    public var cameraV3FlashOffIcon = PaparazzoUITheme.image(named: "flash_off")
    public var cameraV3FlashIconColor = UIColor.white
    public var cameraV3ToggleCameraIcon = PaparazzoUITheme.image(named: "back_front_new")
    public var cameraV3ToggleCameraIconColor = UIColor.white

    public var cameraV3HintViewBackground = UIColor.black.withAlphaComponent(0.6)
    public var cameraV3HintViewFont = UIFont.systemFont(ofSize: 16)
    public var cameraV3HintViewFontColor = UIColor.white
    
    public var cameraV3ShutterScaleFactor = CGFloat(0.85)
    public var cameraV3ShutterEnabledColor = UIColor.white
    public var cameraV3ShutterDisabledColor = UIColor.gray
    
    public var cameraV3SelectedPhotosFont = UIFont.systemFont(ofSize: 15)
    public var cameraV3SelectedPhotosFontColor = UIColor.white

    public var cameraV3BeforeAnimationStrokeColor = UIColor.yellow
    public var cameraV3AfterAnimationStrokeColor = UIColor.white
    
    public var cameraV3AccessDeniedBackgroundColor = UIColor.black
    public var cameraV3AccessDeniedTitleColor = UIColor.white
    public var cameraV3AccessDeniedMessageColor = UIColor.white
    public var cameraV3AccessDeniedButtonTextColor = UIColor.white
    public var cameraV3AccessDeniedTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var cameraV3AccessDeniedMessageFont = UIFont.boldSystemFont(ofSize: 17)
    public var cameraV3AccessDeniedButtonFont = UIFont.boldSystemFont(ofSize: 17)
    public var cameraV3AccessDeniedButtonBackgroundColor: UIColor = UIColor.RGB(red: 0, green: 170, blue: 255, alpha: 1)
    public var cameraV3AccessDeniedButtonCornerRadius: CGFloat = 4
    
    // MARK: - MedicalBookTheme

    public var medicalBookViewBackground = UIColor.black
    
    public var medicalBookCloseIcon = PaparazzoUITheme.image(named: "medicalBookClose")
    public var medicalBookCloseIconColor = UIColor.white
    public var medicalBookFlashOnIcon = PaparazzoUITheme.image(named: "medicalBookLightOn")
    public var medicalBookFlashOffIcon = PaparazzoUITheme.image(named: "medicalBookLightOff")
    public var medicalBookFlashIconColor = UIColor.white
    public var medicalBookToggleCameraIcon = PaparazzoUITheme.image(named: "medicalBookRotateCamera")
    public var medicalBookToggleCameraIconColor = UIColor.white
    
    public var medicalBookHintViewBackground = UIColor.RGB(red: 41, green: 41, blue: 41, alpha: 1)
    public var medicalBookHintViewFont = UIFont.systemFont(ofSize: 15)
    public var medicalBookHintViewFontColor = UIColor.white
    
    public var medicalBookShutterScaleFactor = CGFloat(0.85)
    public var medicalBookShutterEnabledColor = UIColor.white
    public var medicalBookShutterDisabledColor = UIColor.gray
    
    public var medicalBookSelectedPhotosFont = UIFont.systemFont(ofSize: 15)
    public var medicalBookSelectedPhotosFontColor = UIColor.white
    
    public var medicalBookDoneButtonFont = UIFont.systemFont(ofSize: 15)
    public var medicalBookDoneButtonBackground: UIColor = UIColor.RGB(red: 41, green: 41, blue: 41, alpha: 1)
    
    public var medicalBookAccessDeniedBackgroundColor = UIColor.black
    public var medicalBookAccessDeniedTitleColor = UIColor.white
    public var medicalBookAccessDeniedMessageColor = UIColor.white
    public var medicalBookAccessDeniedButtonTextColor = UIColor.white
    public var medicalBookAccessDeniedTitleFont = UIFont.boldSystemFont(ofSize: 17)
    public var medicalBookAccessDeniedMessageFont = UIFont.boldSystemFont(ofSize: 17)
    public var medicalBookAccessDeniedButtonFont = UIFont.boldSystemFont(ofSize: 17)
    
    
    // MARK: - Private
    private static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: Resources.bundle, compatibleWith: nil)
    }
}
