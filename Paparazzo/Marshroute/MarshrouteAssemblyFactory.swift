typealias MarshrouteAssemblyFactoryType = CameraAssemblyFactory & ImageCroppingAssemblyFactory & PhotoLibraryMarshrouteAssemblyFactory

public final class MarshrouteAssemblyFactory:
    CameraAssemblyFactory,
    MediaPickerMarshrouteAssemblyFactory,
    ImageCroppingAssemblyFactory,
    PhotoLibraryMarshrouteAssemblyFactory,
    MaskCropperMarshrouteAssemblyFactory
{
    private let defaultTheme: PaparazzoUITheme
    private let serviceFactory: ServiceFactory
    private let imageStorage: ImageStorage
    
    public init(theme: PaparazzoUITheme = PaparazzoUITheme(),
                imageStorage: ImageStorage = ImageStorageImpl())
    {
        self.defaultTheme = theme
        self.imageStorage = imageStorage
        self.serviceFactory = ServiceFactoryImpl(imageStorage: imageStorage)
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl(
            theme: defaultTheme,
            serviceFactory: serviceFactory
        )
    }
    
    public func mediaPickerAssembly(theme: PaparazzoUITheme?) -> MediaPickerMarshrouteAssembly {
        return MediaPickerMarshrouteAssemblyImpl(
            assemblyFactory: self,
            theme: theme ?? defaultTheme,
            serviceFactory: serviceFactory
        )
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }

    public func photoLibraryAssembly() -> PhotoLibraryMarshrouteAssembly {
        return PhotoLibraryMarshrouteAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }
    
    public func maskCropperAssembly() -> MaskCropperMarshrouteAssembly {
        return MaskCropperMarshrouteAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }
}
