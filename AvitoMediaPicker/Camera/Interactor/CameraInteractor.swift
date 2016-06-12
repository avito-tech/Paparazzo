import UIKit
import AVFoundation

struct CameraPhoto {
    let url: NSURL
    let thumbnailUrl: NSURL
}

protocol CameraInteractor: class {
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? { get set }
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool)
    
    func takePhoto(completion: CameraPhoto? -> ())
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    // Set nil handler to stop observing
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (AbstractImage? -> ())?)
}