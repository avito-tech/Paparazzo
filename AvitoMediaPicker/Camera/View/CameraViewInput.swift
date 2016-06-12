import UIKit
import AVFoundation

enum CameraViewMode {
    case Capture
    case Preview(CameraPhoto)
}

protocol CameraViewInput: class {
    
    func setMode(mode: CameraViewMode)
    func adjustForDeviceOrientation(orientation: DeviceOrientation)
 
    func setCaptureSession(session: AVCaptureSession)
    func setLatestLibraryPhoto(image: AbstractImage?)
    
    func setFlashButtonVisible(visible: Bool)
    func animateFlash()
    
    func addPhoto(photo: CameraPhoto)
    func removeSelectionInPhotoRibbon()
    
    func startSpinnerForNewPhoto()
    func stopSpinnerForNewPhoto()
    
    var onShutterButtonTap: (() -> ())? { get set }
    var onFlashToggle: (Bool -> ())? { get set }
    var onPhotoSelect: (CameraPhoto -> ())? { get set }
    var onReturnToCameraTap: (() -> ())? { get set }
    var onCameraVisibilityChange: ((isCameraVisible: Bool) -> ())? { get set }
}