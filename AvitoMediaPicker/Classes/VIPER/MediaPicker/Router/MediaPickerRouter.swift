import Marshroute

protocol MediaPickerRouter: class, RouterFocusable {
    
    func showPhotoLibrary(
        maxSelectedItemsCount maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    )
    
    func showCroppingModule(
        photo photo: MediaPickerItem,
        configuration: ImageCroppingModule -> ()
    )
}
