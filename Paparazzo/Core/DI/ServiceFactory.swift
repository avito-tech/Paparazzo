import ImageSource

protocol ServiceFactory: class {
    func deviceOrientationService() -> DeviceOrientationService
    func cameraService(initialActiveCameraType: CameraType) -> CameraService
    func photoLibraryLatestPhotoProvider() -> PhotoLibraryLatestPhotoProvider
    func imageCroppingService(image: ImageSource, canvasSize: CGSize) -> ImageCroppingService
    func locationProvider() -> LocationProvider
    func imageMetadataWritingService() -> ImageMetadataWritingService
}

final class ServiceFactoryImpl: ServiceFactory {
    
    private let imageStorage: ImageStorage
    private var cameraService: CameraServiceImpl?
    
    init(imageStorage: ImageStorage) {
        self.imageStorage = imageStorage
    }
    
    func deviceOrientationService() -> DeviceOrientationService {
        return DeviceOrientationServiceImpl()
    }
    
    func cameraService(initialActiveCameraType: CameraType) -> CameraService {
        if let cameraService = cameraService {
            return cameraService
        } else {
            let cameraService = self.cameraService ?? CameraServiceImpl(
                initialActiveCameraType: initialActiveCameraType,
                imageStorage: imageStorage
            )
            self.cameraService = cameraService
            return cameraService
        }
    }
    
    func photoLibraryLatestPhotoProvider() -> PhotoLibraryLatestPhotoProvider {
        return PhotoLibraryLatestPhotoProviderImpl()
    }
    
    func imageCroppingService(image: ImageSource, canvasSize: CGSize) -> ImageCroppingService {
        return ImageCroppingServiceImpl(
            image: image,
            canvasSize: canvasSize,
            imageStorage: imageStorage
        )
    }
    
    func locationProvider() -> LocationProvider {
        return LocationProviderImpl()
    }
    
    func imageMetadataWritingService() -> ImageMetadataWritingService {
        return ImageMetadataWritingServiceImpl()
    }
}
