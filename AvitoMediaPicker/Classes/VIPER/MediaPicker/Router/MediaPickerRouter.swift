import Marshroute

protocol MediaPickerRouter: class, RouterFocusable {
    
    func showPhotoLibrary(_: PhotoLibraryModule -> ())
    
    func showCroppingModule(
        photo photo: MediaPickerItem,
        moduleOutput: ImageCroppingModuleOutput
    )
}
