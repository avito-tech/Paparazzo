import Marshroute
import AvitoMediaPicker

protocol ExampleRouter: class, RouterFocusable, RouterDismissable {

    func showMediaPicker(maxItemsCount maxItemsCount: Int?, output: MediaPickerModuleOutput)
    func showPhotoLibrary(_: PhotoLibraryModule -> ())
}
