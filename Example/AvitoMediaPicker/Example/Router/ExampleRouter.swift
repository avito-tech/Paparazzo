import Marshroute
import AvitoMediaPicker

protocol ExampleRouter: class, RouterFocusable, RouterDismissable {
    func showMediaPicker(maxItemsCount: Int?, output: MediaPickerModuleOutput)
    func showPhotoLibrary(maxItemsCount: Int?, output: PhotoLibraryModuleOutput)
}
