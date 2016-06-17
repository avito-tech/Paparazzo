import Foundation
import AVFoundation

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider

    private var deviceOrientationObserverHandler: (DeviceOrientation -> ())?
    
    init(
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider

        deviceOrientationService.onOrientationChange = { [weak self] orientation in
            self?.deviceOrientationObserverHandler?(orientation)
        }
    }

    // MARK: - MediaPickerInteractor
    
    var onCaptureSessionReady: (AVCaptureSession -> ())? {
        didSet {
            if let captureSession = cameraService.captureSession {
                onCaptureSessionReady?(captureSession)
            }
        }
    }
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?) {
        deviceOrientationObserverHandler = handler
        handler?(deviceOrientationService.currentOrientation)
    }
    
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?) {
        latestLibraryPhotoProvider.observePhoto(handler)
    }
    
    func isFlashAvailable(completion: Bool -> ()) {
        completion(cameraService.isFlashAvailable)
    }
    
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ()) {
        completion(success: cameraService.setFlashEnabled(enabled))
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        cameraService.takePhoto { photo in
            completion(photo.flatMap { MediaPickerItem(image: UrlImageSource(url: $0.url)) })
        }
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
}
