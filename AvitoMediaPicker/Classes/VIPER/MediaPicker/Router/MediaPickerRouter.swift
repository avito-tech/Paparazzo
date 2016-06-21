import Marshroute

protocol MediaPickerRouter: class, RouterFocusable {
    
    func showPhotoLibrary(maxItemsCount maxItemsCount: Int?, moduleOutput: PhotoLibraryModuleOutput)
    
    func showCroppingModule(
        photo photo: MediaPickerItem,
        moduleOutput: ImageCroppingModuleOutput
    )
}
