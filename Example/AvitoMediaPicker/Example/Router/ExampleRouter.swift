import Marshroute
import AvitoMediaPicker

protocol ExampleRouter: class, RouterFocusable, RouterDismissable {

    func showMediaPicker(maxItemsCount maxItemsCount: Int?, configuration: MediaPickerModule -> ())
    
    func showPhotoLibrary(
        maxSelectedItemsCount maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    )
}
