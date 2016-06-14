protocol CameraRouter: class {
    
    func showPhotoLibrary(moduleOutput moduleOutput: PhotoLibraryModuleOutput)
    
    func showCroppingModule(
        photo photo: AnyObject /* TODO */,
        moduleOutput: ImageCroppingModuleOutput
    )
}
