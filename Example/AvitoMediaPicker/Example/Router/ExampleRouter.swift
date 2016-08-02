import Marshroute
import AvitoMediaPicker

protocol ExampleRouter: class, RouterFocusable, RouterDismissable {

    func showMediaPicker(maxItemsCount maxItemsCount: Int?, configuration: MediaPickerModule -> ())
    
    func showPhotoLibrary(
        selectedItems selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    )
}
