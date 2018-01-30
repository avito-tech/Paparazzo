public final class AssemblyFactory:
    CameraAssemblyFactory,
    MediaPickerAssemblyFactory,
    PhotoLibraryAssemblyFactory,
    ImageCroppingAssemblyFactory,
    MaskCropperAssemblyFactory
{
    
    private let defaultTheme: PaparazzoUITheme
    private let serviceFactory: ServiceFactory
    
    public init(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        imageStorage: ImageStorage = ImageStorageImpl())
    {
        self.defaultTheme = theme
        self.serviceFactory = ServiceFactoryImpl(imageStorage: imageStorage)
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }
    
    public func mediaPickerAssembly(theme: PaparazzoUITheme?) -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(
            assemblyFactory: self,
            theme: theme ?? defaultTheme,
            serviceFactory: serviceFactory
        )
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }

    public func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }
    
    public func maskCropperAssembly() -> MaskCropperAssembly {
        return MaskCropperAssemblyImpl(theme: defaultTheme, serviceFactory: serviceFactory)
    }
}
