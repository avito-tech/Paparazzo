public final class AssemblyFactory: CameraAssemblyFactory, MediaPickerAssemblyFactory, ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory {
    
    private let theme: MediaPickerUITheme
    
    public init(theme: MediaPickerUITheme = MediaPickerUITheme()) {
        self.theme = theme
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl()
    }
    
    public func mediaPickerAssembly() -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(assemblyFactory: self, theme: theme)
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl()
    }

    public func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl(theme: theme)
    }
}