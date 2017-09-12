import ImageSource

protocol ServiceFactory: class {
    func deviceOrientationService() -> DeviceOrientationService
    func cameraService(initialActiveCameraType: CameraType) -> CameraService
    func photoLibraryLatestPhotoProvider() -> PhotoLibraryLatestPhotoProvider
    func imageCroppingService(image: ImageSource, canvasSize: CGSize) -> ImageCroppingService
}

final class ServiceFactoryImpl: ServiceFactory {
    
    private let photoStorage: PhotoStorage
    
    init(photoStorage: PhotoStorage) {
        self.photoStorage = photoStorage
    }
    
    func deviceOrientationService() -> DeviceOrientationService {
        return DeviceOrientationServiceImpl()
    }
    
    func cameraService(initialActiveCameraType: CameraType) -> CameraService {
        return CameraServiceImpl(
            initialActiveCameraType: initialActiveCameraType,
            photoStorage: photoStorage
        )
    }
    
    func photoLibraryLatestPhotoProvider() -> PhotoLibraryLatestPhotoProvider {
        return PhotoLibraryLatestPhotoProviderImpl()
    }
    
    func imageCroppingService(image: ImageSource, canvasSize: CGSize) -> ImageCroppingService {
        return ImageCroppingServiceImpl(image: image, canvasSize: canvasSize)
    }
    
}
