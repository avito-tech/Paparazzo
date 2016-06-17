import UIKit
import AVFoundation

protocol MediaPickerInteractor: class {
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? { get set }
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ())
    
    func addPhotoLibraryItems(items: [AnyObject], completion: ())
    func removeItem(item: MediaPickerItem)
    
    func takePhoto(completion: (item: MediaPickerItem?, canTakeMorePhotos: Bool) -> ())
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ())
    
    // Set nil handler to stop observing
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}