typealias MarshrouteAssemblyFactoryType = CameraAssemblyFactory & ImageCroppingAssemblyFactory & PhotoLibraryMarshrouteAssemblyFactory

public final class MarshrouteAssemblyFactory:
    CameraAssemblyFactory,
    MediaPickerMarshrouteAssemblyFactory,
    ImageCroppingAssemblyFactory,
    PhotoLibraryMarshrouteAssemblyFactory,
    PhotoLibraryV2MarshrouteAssemblyFactory,
    MaskCropperMarshrouteAssemblyFactory,
    ScannerMarshrouteAssemblyFactory
{
    private let theme: PaparazzoUITheme
    private let serviceFactory: ServiceFactory
    private let imageStorage: ImageStorage
    
    public init(theme: PaparazzoUITheme = PaparazzoUITheme(),
                imageStorage: ImageStorage = ImageStorageImpl())
    {
        self.theme = theme
        self.imageStorage = imageStorage
        self.serviceFactory = ServiceFactoryImpl(imageStorage: imageStorage)
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl(
            theme: theme,
            serviceFactory: serviceFactory
        )
    }
    
    public func mediaPickerAssembly() -> MediaPickerMarshrouteAssembly {
        return MediaPickerMarshrouteAssemblyImpl(
            assemblyFactory: self,
            theme: theme,
            serviceFactory: serviceFactory
        )
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }

    public func photoLibraryAssembly() -> PhotoLibraryMarshrouteAssembly {
        return PhotoLibraryMarshrouteAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly {
        return PhotoLibraryV2MarshrouteAssemblyImpl(assemblyFactory: self, theme: theme, serviceFactory: serviceFactory)
    }
    
    public func maskCropperAssembly() -> MaskCropperMarshrouteAssembly {
        return MaskCropperMarshrouteAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func scannerAssembly() -> ScannerMarshrouteAssembly {
        return ScannerMarshrouteAssemblyImpl(assemblyFactory: self, theme: theme, serviceFactory: serviceFactory)
    }
}
