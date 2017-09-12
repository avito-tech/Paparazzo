import ImageSource

final class CameraInteractorImpl: CameraInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private var previewImagesSizeForNewPhotos: CGSize?
    
    init(cameraService: CameraService, deviceOrientationService: DeviceOrientationService) {
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
    }
    
    // MARK: - CameraInteractor

    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ()) {
        cameraService.getCaptureSession { [cameraService] captureSession in
            cameraService.getOutputOrientation { outputOrientation in
                dispatch_to_main_queue {
                    completion(captureSession.flatMap { CameraOutputParameters(captureSession: $0, orientation: outputOrientation) })
                }
            }
        }
    }
    
    func isFlashAvailable(completion: (Bool) -> ()) {
        completion(cameraService.isFlashAvailable)
    }
    
    func isFlashEnabled(completion: @escaping (Bool) -> ()) {
        completion(cameraService.isFlashEnabled)
    }
    
    func setFlashEnabled(_ enabled: Bool, completion: ((_ success: Bool) -> ())?) {
        let success = cameraService.setFlashEnabled(enabled)
        completion?(success)
    }
    
    func canToggleCamera(completion: @escaping (Bool) -> ()) {
        cameraService.canToggleCamera(completion: completion)
    }
    
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ()) {
        cameraService.toggleCamera(completion: completion)
    }
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ()) {
        
        cameraService.takePhoto { [weak self] photo in
            
            let imageSource = photo.flatMap { LocalImageSource(path: $0.path) }
            
            if let imageSource = imageSource, let previewSize = self?.previewImagesSizeForNewPhotos {
                
                let previewOptions = ImageRequestOptions(size: .fillSize(previewSize), deliveryMode: .best)
                
                imageSource.requestImage(options: previewOptions) { (result: ImageRequestResult<CGImageWrapper>) in
                    let imageSourceWithPreview = photo.flatMap {
                        LocalImageSource(path: $0.path, previewImage: result.image?.image)
                    }
                    completion(imageSourceWithPreview.flatMap { MediaPickerItem(image: $0, source: .camera) })
                }
                
            } else {
                completion(imageSource.flatMap { MediaPickerItem(image: $0, source: .camera) })
            }
        }
    }
    
    func setPreviewImagesSizeForNewPhotos(_ size: CGSize) {
        previewImagesSizeForNewPhotos = CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    func setCameraOutputNeeded(_ isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = handler
        handler(deviceOrientationService.currentOrientation)
    }
    
    func focusCameraOnPoint(_ focusPoint: CGPoint) -> Bool {
        return cameraService.focusOnPoint(focusPoint)
    }
}
