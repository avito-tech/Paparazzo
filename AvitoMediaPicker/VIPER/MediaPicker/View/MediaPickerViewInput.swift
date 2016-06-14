import UIKit
import AVFoundation

enum MediaPickerViewMode {
    case Camera
    case PhotoPreview(MediaPickerItem)
}

protocol MediaPickerViewInput: class {
    
    func setMode(mode: MediaPickerViewMode)
    func adjustForDeviceOrientation(orientation: DeviceOrientation)

    func setCaptureSession(session: AVCaptureSession)
    func setLatestLibraryPhoto(image: LazyImage?)
    
    func setFlashButtonVisible(visible: Bool)
    func animateFlash()
    
    func addPhotoRibbonItem(photo: MediaPickerItem)
    func removeSelectionInPhotoRibbon()
    
    func startSpinnerForNewPhoto()
    func stopSpinnerForNewPhoto()
    
    var onCameraVisibilityChange: ((isCameraVisible: Bool) -> ())? { get set }
    
    // MARK: - Actions in photo ribbon
    var onPhotoSelect: (MediaPickerItem -> ())? { get set }
    
    // MARK: - Camera actions
    var onPhotoLibraryButtonTap: (() -> ())? { get set }
    var onShutterButtonTap: (() -> ())? { get set }
    var onFlashToggle: (Bool -> ())? { get set }
    
    // MARK: - Selected photo actions
    var onRemoveButtonTap: (() -> ())? { get set }
    var onCropButtonTap: (() -> ())? { get set }
    var onReturnToCameraTap: (() -> ())? { get set }
}