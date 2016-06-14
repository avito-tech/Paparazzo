final class AssemblyFactory: ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory {

    func imageCroppingAssembly() -> ImageCroppingAssembly {
        return ImageCroppingAssemblyImpl()
    }

    func photoLibraryAssembly() -> PhotoLibraryAssembly {
        return PhotoLibraryAssemblyImpl()
    }
}