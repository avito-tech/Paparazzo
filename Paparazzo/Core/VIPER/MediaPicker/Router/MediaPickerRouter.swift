import ImageSource

protocol MediaPickerRouter: class {
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
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
