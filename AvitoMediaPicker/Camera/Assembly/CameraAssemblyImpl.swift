import UIKit
import Marshroute

final class CameraAssemblyImpl: CameraAssembly {
    
    // MARK: - MediaPickerAssembly
    
    func viewController() -> UIViewController {
        
        let imageResizingService = ImageResizingServiceImpl()
        
        let interactor = CameraInteractorImpl(
            cameraService: CameraServiceImpl(imageResizingService: imageResizingService),
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl()
        )
        
        let mediaPickerPresenter = CameraPresenter(
            interactor: interactor
        )
        
        let viewController = CameraViewController()
        viewController.addDisposable(mediaPickerPresenter)
        
        mediaPickerPresenter.view = viewController
        
        return viewController
    }
}
