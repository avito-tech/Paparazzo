public final class AssemblyFactory:
    CameraAssemblyFactory,
    NewCameraAssemblyFactory,
    MediaPickerAssemblyFactory,
    PhotoLibraryAssemblyFactory,
    PhotoLibraryV2AssemblyFactory,
    ImageCroppingAssemblyFactory,
    MaskCropperAssemblyFactory,
    LimitedAccessAlertFactory
{
    private let theme: PaparazzoUITheme
    private let serviceFactory: ServiceFactory
    private let alertFactory: LimitedAccessAlertFactory
    
    public init(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        imageStorage: ImageStorage = ImageStorageImpl(),
        limitedAccessAlertFactory: LimitedAccessAlertFactory = LimitedAccessAlertFactoryImpl())
    {
        self.theme = theme
        self.serviceFactory = ServiceFactoryImpl(imageStorage: imageStorage)
        self.alertFactory = limitedAccessAlertFactory
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl(theme: theme, serviceFactory: serviceFactory)
    }
    
    func newCameraAssembly() -> NewCameraAssembly {
        return NewCameraAssemblyImpl(assemblyFactory: self, theme: theme, serviceFactory: serviceFactory)
    }
    
    public func mediaPickerAssembly() -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(
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
