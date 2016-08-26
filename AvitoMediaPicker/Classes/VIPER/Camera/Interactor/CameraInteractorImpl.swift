import AVFoundation

final class CameraInteractorImpl: CameraInteractor {
    
    private let cameraService: CameraService
    private var previewImagesSizeForNewPhotos: CGSize?
    
    init(cameraService: CameraService, deviceOrientationService: DeviceOrientationService) {
        self.cameraService = cameraService
    }
    
    // MARK: - CameraInteractor

    func getOutputParameters(completion: CameraOutputParameters? -> ()) {
        cameraService.getCaptureSession { [cameraService] captureSession in
            cameraService.getOutputOrientation { outputOrientation in
                dispatch_to_main_queue {
                    completion(captureSession.flatMap { CameraOutputParameters(captureSession: $0, orientation: outputOrientation) })
                }
            }
        }
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
    
    func toggleCamera(completion: (newOutputOrientation: ExifOrientation) -> ()) {
        cameraService.toggleCamera(completion)
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        
        cameraService.takePhoto { [weak self] photo in
            
            let imageSource = photo.flatMap { LocalImageSource(path: $0.path) }
            
            if let imageSource = imageSource, previewSize = self?.previewImagesSizeForNewPhotos {
                
                let previewOptions = ImageRequestOptions(size: .FillSize(previewSize), deliveryMode: .Best)
                
                imageSource.requestImage(options: previewOptions) { (result: ImageRequestResult<CGImageWrapper>) in
                    let imageSourceWithPreview = photo.flatMap {
                        LocalImageSource(path: $0.path, previewImage: result.image?.image)
                    }
                    completion(imageSourceWithPreview.flatMap { MediaPickerItem(image: $0, source: .Camera) })
                }
                
            } else {
                completion(imageSource.flatMap { MediaPickerItem(image: $0, source: .Camera) })
            }
        }
    }
    
    func setPreviewImagesSizeForNewPhotos(size: CGSize) {
        previewImagesSizeForNewPhotos = CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
}
