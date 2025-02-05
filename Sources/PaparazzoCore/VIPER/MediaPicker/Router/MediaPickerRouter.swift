import ImageSource
import UIKit

protocol MediaPickerRouter: AnyObject {
    func showPhotoLibrary(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ()
    )
    
    func showCroppingModule(
        forImage: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ()
    )
    
    func focusOnCurrentModule()
    func dismissCurrentModule()
}
