import Marshroute
import AvitoDesignKit

protocol MediaPickerRouter: class, RouterFocusable, RouterDismissable {
    
    func showPhotoLibrary(
        maxSelectedItemsCount maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    )
    
    func showCroppingModule(
        forImage image: ImageSource,
        configuration: ImageCroppingModule -> ()
    )
}
