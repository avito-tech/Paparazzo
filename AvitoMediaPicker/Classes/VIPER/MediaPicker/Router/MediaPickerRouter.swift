import Marshroute
import AvitoDesignKit

protocol MediaPickerRouter: class, RouterFocusable, RouterDismissable {
    
    func showPhotoLibrary(
        selectedItems selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    )
    
    func showCroppingModule(
        forImage image: ImageSource,
        canvasSize: CGSize,
        configuration: ImageCroppingModule -> ()
    )
}
