import Marshroute
import AvitoMediaPicker

protocol ExampleRouter: class, RouterFocusable, RouterDismissable {

    func showMediaPicker(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropCanvasSize: CGSize,
        configuration: (MediaPickerModule) -> ()
    )
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: (PhotoLibraryModule) -> ()
    )
}
