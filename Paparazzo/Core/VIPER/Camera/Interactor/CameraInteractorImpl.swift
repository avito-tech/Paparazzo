import ImageSource
import CoreLocation

final class CameraInteractorImpl: CameraInteractor {
    
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let locationProvider: LocationProvider
    private var previewImagesSizeForNewPhotos: CGSize?
    
    init(
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        locationProvider: LocationProvider)
    {
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.locationProvider = locationProvider
    }
    
    // MARK: - CameraInteractor

    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ()) {
        cameraService.getCaptureSession { [cameraService] captureSession in
            cameraService.getOutputOrientation { outputOrientation in
                dispatch_to_main_queue {
                    completion(captureSession.flatMap { CameraOutputParameters(
                        captureSession: $0,
                        orientation: outputOrientation,
                        isMetalEnabled: cameraService.isMetalEnabled)
                    })
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
            if let locationProvider = self?.locationProvider {
                locationProvider.location { location in
                    self?.mediaPickerItem(photo?.path, location: location, completion: completion)
                }
            } else {
                self?.mediaPickerItem(photo?.path, completion: completion)
            }
        }
    }
    
    private func mediaPickerItem(_ photoPath: String?, location: CLLocation? = nil, completion: @escaping (MediaPickerItem?) -> ()) {
        guard let photoPath = photoPath else {
            completion(nil)
            return
        }
        
        let imageSource = LocalImageSource(
            path: photoPath,
            additionalMetadata: GPSMetadataExtractor.gpsMetaFromLocation(location)
        )
        
        if let previewSize = previewImagesSizeForNewPhotos {
            
            let previewOptions = ImageRequestOptions(size: .fillSize(previewSize), deliveryMode: .best)
            
            imageSource.requestImage(options: previewOptions) { (result: ImageRequestResult<CGImageWrapper>) in
                let imageSourceWithPreview = LocalImageSource(
                    path: imageSource.path,
                    previewImage: result.image?.image,
                    additionalMetadata: imageSource.additionalMetadata
                )
                let item = MediaPickerItem(image: imageSourceWithPreview, source: .camera)
                completion(item)
            }
        } else {
            let item = MediaPickerItem(image: imageSource, source: .camera)
            completion(item)
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

private final class GPSMetadataExtractor {
    
    static func gpsMetaFromLocation(_ location: CLLocation?) -> [String: Any] {
        guard let coordinate = location?.coordinate else {
            return [:]
        }
        let latitudeRef = coordinate.latitude < 0.0 ? "S" : "N"
        let longitudeRef = coordinate.longitude < 0.0 ? "W" : "E"
        
        let dict: [String : Any] = [
            "GPSLatitude": coordinate.latitude,
            "GPSLatitudeRef": latitudeRef,
            "GPSLongitude": coordinate.longitude,
            "GPSLongitudeRef": longitudeRef
        ]
        return ["GPS": dict]
    }
}
