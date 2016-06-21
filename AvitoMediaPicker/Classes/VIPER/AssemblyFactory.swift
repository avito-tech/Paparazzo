public final class AssemblyFactory: CameraAssemblyFactory, MediaPickerAssemblyFactory, ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory {
    
    private let colors: MediaPickerColors
    
    public init(colors: MediaPickerColors = MediaPickerColors()) {
        self.colors = colors
    }
    
    func cameraAssembly() -> CameraAssembly {
        return CameraAssemblyImpl()
    }
    
    public func mediaPickerAssembly() -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(assemblyFactory: self, colors: colors)
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl()
    }

    public func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl(colors: colors)
    }
}