public final class AssemblyFactory: CameraAssemblyFactory, MediaPickerAssemblyFactory, ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory {
    
    private let theme: PaparazzoUITheme
    
    public init(theme: PaparazzoUITheme = PaparazzoUITheme()) {
        self.theme = theme
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl(theme: theme)
    }
    
    public func mediaPickerAssembly() -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(assemblyFactory: self, theme: theme)
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl(theme: theme)
    }

    public func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl(theme: theme)
    }
}
