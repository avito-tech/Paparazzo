import ImageSource
import UIKit

enum MediaPickerViewMode {
    case camera
    case photoPreview(MediaPickerItem)
}

enum MediaPickerTitleStyle {
    case dark
    case light
}

enum MediaPickerAutocorrectionStatus {
    case original
    case corrected
}

enum MediaPickerAutoEnhanceStatus {
    case original
    case enhanced
    case disabled
}

protocol MediaPickerViewInput: AnyObject {
    
    func setMode(_: MediaPickerViewMode)
    func setAutocorrectionStatus(_: MediaPickerAutocorrectionStatus)
    func setAutoEnhanceStatus(_: MediaPickerAutoEnhanceStatus)
    func adjustForDeviceOrientation(_: DeviceOrientation)
    
    func setCameraOutputParameters(_: CameraOutputParameters)
    func setCameraOutputOrientation(_: ExifOrientation)
    
    func setPhotoTitle(_: String)
    func setPreferredPhotoTitleStyle(_: MediaPickerTitleStyle)
    func setPhotoTitleAlpha(_: CGFloat)
    func setContinueButtonTitle(_: String)
    func setContinueButtonEnabled(_: Bool)
    func setContinueButtonStyle(_: MediaPickerContinueButtonStyle)
    func setContinueButtonPlacement(_: MediaPickerContinueButtonPlacement)
    
    func setLatestLibraryPhoto(_: ImageSource?)
    
    func setFlashButtonVisible(_: Bool)
    func setFlashButtonOn(_: Bool)
    func animateFlash()
    
    func addItems(_: [MediaPickerItem], animated: Bool, completion: @escaping () -> ())
    func updateItem(_: MediaPickerItem)
    func removeItem(_: MediaPickerItem)
    func selectItem(_: MediaPickerItem)
    func moveItem(from sourceIndex: Int, to destinationIndex: Int)
    func moveItemThumbnail(from sourceIndex: Int, to destinationIndex: Int)
    func scrollToItemThumbnail(_: MediaPickerItem, animated: Bool)
    
    func selectCamera()
    func scrollToCameraThumbnail(animated: Bool)
    
    func setCameraControlsEnabled(_: Bool)
    func setCameraButtonVisible(_: Bool)
    func setShutterButtonEnabled(_: Bool)
    func setPhotoLibraryButtonEnabled(_: Bool)
    func setPhotoLibraryButtonVisible(_: Bool)
    
    func setImagePerceptionBadge(_ badge: ImagePerceptionBadgeViewData)
    
    var onCloseButtonTap: (() -> ())? { get set }
    var onContinueButtonTap: (() -> ())? { get set }
    
    var onCameraToggleButtonTap: (() -> ())? { get set }
    func setCameraToggleButtonVisible(_: Bool)
    
    func setContinueButtonVisible(_: Bool)
    
    func setShowPreview(_: Bool)
    
    func showInfoMessage(_: String, timeout: TimeInterval)
    
    // MARK: - Actions in photo ribbon
    var onItemSelect: ((MediaPickerItem) -> ())? { get set }
    var onItemMove: ((_ sourceIndex: Int, _ destinationIndex: Int) -> ())? { get set }
    
    // MARK: - Camera actions
    var onPhotoLibraryButtonTap: (() -> ())? { get set }
    var onShutterButtonTap: (() -> ())? { get set }
    var onFlashToggle: ((Bool) -> ())? { get set }
    
    // MARK: - Selected photo actions
    var onRemoveButtonTap: (() -> ())? { get set }
    var onAutocorrectButtonTap: (() -> ())? { get set }
    var onCropButtonTap: (() -> ())? { get set }
    var onCameraThumbnailTap: (() -> ())? { get set }
    var onAutoEnhanceButtonTap: (() -> ())? { get set }
    
    var onSwipeToItem: ((MediaPickerItem) -> ())? { get set }
    var onSwipeToCamera: (() -> ())? { get set }
    var onSwipeToCameraProgressChange: ((CGFloat) -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    var onViewDidAppear: ((_ animated: Bool) -> ())? { get set }
    var onViewWillAppear: ((_ animated: Bool) -> ())? { get set }
    var onViewDidDisappear: ((_ animated: Bool) -> ())? { get set }
    
    var onPreviewSizeDetermined: ((_ previewSize: CGSize) -> ())? { get set }
}
