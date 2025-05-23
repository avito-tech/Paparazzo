import ImageSource
import UIKit

protocol ServiceFactory: AnyObject {
    func deviceOrientationService() -> DeviceOrientationService
    func cameraService(initialActiveCameraType: CameraType) -> CameraService
    func cameraStatusService() -> CameraStatusService
    func photoLibraryLatestPhotoProvider() -> PhotoLibraryLatestPhotoProvider
    func imageCroppingService(image: ImageSource, canvasSize: CGSize) -> ImageCroppingService
    func locationProvider() -> LocationProvider
    func imageMetadataWritingService() -> ImageMetadataWritingService
    func volumeService() -> VolumeService
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
    
    func cameraStatusService() -> CameraStatusService {
        CameraStatusServiceImpl()
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
    
    func volumeService() -> VolumeService {
        VolumeServiceImpl()
    }
}
