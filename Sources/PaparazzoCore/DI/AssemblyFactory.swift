import UIKit

public final class AssemblyFactory:
    CameraAssemblyFactory,
    MediaPickerAssemblyFactory,
    PhotoLibraryAssemblyFactory,
    PhotoLibraryV2AssemblyFactory,
    ImageCroppingAssemblyFactory,
    MaskCropperAssemblyFactory,
    LimitedAccessAlertFactory,
    CameraV3AssemblyFactory,
    MedicalBookCameraAssemblyFactory
{
    private let isPhotoFetchLimitEnabled: Bool
    private let theme: PaparazzoUITheme
    private let serviceFactory: ServiceFactory
    private let alertFactory: LimitedAccessAlertFactory
    
    public init(
        isPhotoFetchLimitEnabled: Bool,
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        imageStorage: ImageStorage = ImageStorageImpl(),
        limitedAccessAlertFactory: LimitedAccessAlertFactory = LimitedAccessAlertFactoryImpl())
    {
        self.isPhotoFetchLimitEnabled = isPhotoFetchLimitEnabled
        self.theme = theme
        self.serviceFactory = ServiceFactoryImpl(imageStorage: imageStorage)
        self.alertFactory = limitedAccessAlertFactory
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }
    
    func cameraV3Assembly() -> CameraV3Assembly {
        CameraV3AssemblyImpl(assemblyFactory: self, theme: theme, serviceFactory: serviceFactory)
    }
    
    func medicalBookCameraAssembly() -> MedicalBookCameraAssembly {
        MedicalBookCameraAssemblyImpl(
            assemblyFactory: self,
            theme: theme,
            serviceFactory: serviceFactory
        )
    }
    
    public func mediaPickerAssembly() -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
            assemblyFactory: self,
            theme: theme,
            serviceFactory: serviceFactory
        )
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }

    public func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func photoLibraryV2Assembly() -> PhotoLibraryV2Assembly {
        return PhotoLibraryV2AssemblyImpl(
            assemblyFactory: self,
            theme: theme,
            serviceFactory: serviceFactory
        )
    }
    
    public func maskCropperAssembly() -> MaskCropperAssembly {
        return MaskCropperAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }
    
    @available(iOS 14, *)
    public func limitedAccessAlert() -> UIAlertController {
        return alertFactory.limitedAccessAlert()
    }
}
