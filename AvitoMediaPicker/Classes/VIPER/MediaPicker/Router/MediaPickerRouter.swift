protocol MediaPickerRouter: class {
    
    func showPhotoLibrary(maxItemsCount maxItemsCount: Int?, moduleOutput: PhotoLibraryModuleOutput)
    
    func showCroppingModule(
        photo photo: AnyObject /* TODO */,
        moduleOutput: ImageCroppingModuleOutput
    )
}
