import UIKit
import AVFoundation

enum MediaPickerViewMode {
    case Camera
    case PhotoPreview(MediaPickerItem)
}

protocol MediaPickerViewInput: class {
    
    func setMode(_: MediaPickerViewMode)
    func adjustForDeviceOrientation(_: DeviceOrientation)
    
    func setCaptureSession(_: AVCaptureSession)
    
    func setContinueButtonTitle(_: String)

    func setLatestLibraryPhoto(_: ImageSource?)
    
    func setFlashButtonVisible(_: Bool)
    func setFlashButtonOn(_: Bool)
    func animateFlash()
    
    func addItems(_: [MediaPickerItem], animated: Bool)
    func removeItem(_: MediaPickerItem)
    func selectItem(_: MediaPickerItem)
    func scrollToItemThumbnail(_: MediaPickerItem, animated: Bool)
    
    func selectCamera()
    func scrollToCameraThumbnail(animated animated: Bool)
    
    func setCameraButtonVisible(_: Bool)
    func setShutterButtonEnabled(_: Bool)
    
    var onCloseButtonTap: (() -> ())? { get set }
    var onContinueButtonTap: (() -> ())? { get set }
    
    var onCameraToggleButtonTap: (() -> ())? { get set }
    func setCameraToggleButtonVisible(_: Bool)
    
    // MARK: - Actions in photo ribbon
    var onItemSelect: (MediaPickerItem -> ())? { get set }
    
    // MARK: - Camera actions
    var onPhotoLibraryButtonTap: (() -> ())? { get set }
    var onShutterButtonTap: (() -> ())? { get set }
    var onFlashToggle: (Bool -> ())? { get set }
    
    // MARK: - Selected photo actions
    var onRemoveButtonTap: (() -> ())? { get set }
    var onCropButtonTap: (() -> ())? { get set }
    var onReturnToCameraTap: (() -> ())? { get set }
    
    var onSwipeToItem: (MediaPickerItem -> ())? { get set }
    var onSwipeToCamera: (() -> ())? { get set }
}