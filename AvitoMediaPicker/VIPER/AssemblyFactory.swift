final class AssemblyFactory: MediaPickerAssemblyFactory, ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory {
    
    func mediaPickerAssembly() -> MediaPickerAssembly {
        return MediaPickerAssemblyImpl(assemblyFactory: self)
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl()
    }

    func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl()
    }
}