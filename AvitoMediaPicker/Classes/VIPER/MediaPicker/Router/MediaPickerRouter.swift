import ImageSource
import Marshroute

protocol MediaPickerRouter: class, RouterFocusable, RouterDismissable {
    
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
}
