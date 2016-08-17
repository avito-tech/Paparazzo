import AVFoundation

final class CameraInteractorImpl: CameraInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    
    private var onDeviceOrientationChange: (DeviceOrientation -> ())?
    private var previewImagesSizeForNewPhotos: CGSize?
    
    init(cameraService: CameraService, deviceOrientationService: DeviceOrientationService) {
        
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        
        deviceOrientationService.onOrientationChange = { [weak self] orientation in
            self?.onDeviceOrientationChange?(orientation)
        }
    }
    
    // MARK: - CameraInteractor

    func getCaptureSession(completion: AVCaptureSession? -> ()) {
        cameraService.captureSession { captureSession in
            dispatch_async(dispatch_get_main_queue()) {
                completion(captureSession)
            }
            
        }
    }

    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?) {
        onDeviceOrientationChange = handler
        handler?(deviceOrientationService.currentOrientation)
    }
    
    func isFlashAvailable(completion: Bool -> ()) {
        completion(cameraService.isFlashAvailable)
    }
    
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ()) {
        completion(success: cameraService.setFlashEnabled(enabled))
    }
    
    func canToggleCamera(completion: Bool -> ()) {
        cameraService.canToggleCamera(completion)
    }
    
    func toggleCamera() {
        cameraService.toggleCamera()
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        
        cameraService.takePhoto { [weak self] photo in
            
            let imageSource = photo.flatMap { UrlImageSource(url: $0.url) }
            
            if let imageSource = imageSource, previewSize = self?.previewImagesSizeForNewPhotos {
                imageSource.imageFittingSize(previewSize, contentMode: .AspectFill, deliveryMode: .Best) { (imageWrapper: CGImageWrapper?) in
                    let imageSource = photo.flatMap { UrlImageSource(url: $0.url, previewImage: imageWrapper?.image) }
                    completion(imageSource.flatMap { MediaPickerItem(image: $0, source: .Camera) })
                }
            } else {
                completion(imageSource.flatMap { MediaPickerItem(image: $0, source: .Camera) })
            }
        }
    }
    
    func setPreviewImagesSizeForNewPhotos(size: CGSize) {
        previewImagesSizeForNewPhotos = size
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
}
