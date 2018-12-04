import ImageSource

protocol ServiceFactory: class {
    func deviceOrientationService() -> DeviceOrientationService
    func cameraService(initialActiveCameraType: CameraType) -> CameraService
    func photoLibraryLatestPhotoProvider() -> PhotoLibraryLatestPhotoProvider
    func imageCroppingService(image: ImageSource, canvasSize: CGSize) -> ImageCroppingService
    func locationProvider() -> LocationProvider
}

final class ServiceFactoryImpl: ServiceFactory {
    
    private let imageStorage: ImageStorage
    
    init(imageStorage: ImageStorage) {
        self.imageStorage = imageStorage
    }
    
    func deviceOrientationService() -> DeviceOrientationService {
        return DeviceOrientationServiceImpl()
    }
    
    func cameraService(initialActiveCameraType: CameraType) -> CameraService {
        return CameraServiceImpl(
            initialActiveCameraType: initialActiveCameraType,
            imageStorage: imageStorage
        )
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
}
