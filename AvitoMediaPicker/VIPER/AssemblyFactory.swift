final class AssemblyFactory: PhotoPickerAssemblyFactory, ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory {
    
    func photoPickerAssembly() -> PhotoPickerAssembly {
        return PhotoPickerAssemblyImpl(assemblyFactory: self)
    }

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl()
    }

    func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl()
    }
}