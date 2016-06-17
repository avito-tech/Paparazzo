import UIKit
import AVFoundation

protocol MediaPickerInteractor: class {
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? { get set }
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ())
    
    func takePhoto(completion: MediaPickerItem? -> ())
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    // Set nil handler to stop observing
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}