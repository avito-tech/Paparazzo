import Marshroute
import Paparazzo

protocol ExampleRouter: RouterFocusable, RouterDismissable {

    func showMediaPicker(
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ()
    )
    
    func showMaskCropper(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        configure: (MaskCropperModule) -> ()
    )
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configure: (PhotoLibraryModule) -> ()
    )
    
    func showPhotoLibraryV2(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configure: (PhotoLibraryV2Module) -> ()
    )
    
    func showScanner(
        data: ScannerData,
        configure: (ScannerModule) -> ()
    )
}
