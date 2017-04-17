import Marshroute
import Paparazzo

protocol ExampleRouter: class, RouterFocusable, RouterDismissable {

    func showMediaPicker(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropCanvasSize: CGSize,
        configure: (MediaPickerModule) -> ()
    )
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configure: (PhotoLibraryModule) -> ()
    )
}
