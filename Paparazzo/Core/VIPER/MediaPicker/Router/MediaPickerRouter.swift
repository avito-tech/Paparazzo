import ImageSource

protocol MediaPickerRouter: class {
    
    func showPhotoLibrary(
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ()
    )
    
    func showCroppingModule(
        forImage: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ()
    )
    
    func focusOnCurrentModule()
    func dismissCurrentModule()
}
