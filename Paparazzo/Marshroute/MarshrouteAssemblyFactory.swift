public final class MarshrouteAssemblyFactory:
    CameraAssemblyFactory,
    MediaPickerMarshrouteAssemblyFactory,
    ImageCroppingAssemblyFactory,
    PhotoLibraryMarshrouteAssemblyFactory
{
    private let theme: PaparazzoUITheme
    
    public init(theme: PaparazzoUITheme = PaparazzoUITheme()) {
        self.theme = theme
    }
    
    func cameraAssembly(initialActiveCamera: CameraType) -> CameraAssembly {
        return CameraAssemblyImpl(theme: theme, initialActiveCamera: initialActiveCamera)
    }
    
    public func mediaPickerAssembly() -> MediaPickerMarshrouteAssembly {
        return MediaPickerMarshrouteAssemblyImpl(assemblyFactory: self, theme: theme)
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl(theme: theme)
    }

    public func photoLibraryAssembly() -> PhotoLibraryMarshrouteAssembly {
        return PhotoLibraryMarshrouteAssemblyImpl(theme: theme)
    }
}
