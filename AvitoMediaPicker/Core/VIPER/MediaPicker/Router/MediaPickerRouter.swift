import ImageSource

protocol MediaPickerRouter: class {
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: (PhotoLibraryModule) -> ()
    )
    
    func showCroppingModule(
        forImage: ImageSource,
        canvasSize: CGSize,
        configuration: (ImageCroppingModule) -> ()
    )
    
    func focusOnCurrentModule()
    func dismissCurrentModule()
}
