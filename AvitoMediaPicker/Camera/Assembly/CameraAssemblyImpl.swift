import UIKit
import Marshroute

final class CameraAssemblyImpl: CameraAssembly {
    
    // MARK: - MediaPickerAssembly
    
    func viewController() -> UIViewController {

        let imageResizingService = ImageResizingServiceImpl()
        let cameraService = CameraServiceImpl(imageResizingService: imageResizingService)
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl()
        )

        let router = CameraRouterImpl()
        
        let mediaPickerPresenter = CameraPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = CameraViewController()
        viewController.addDisposable(mediaPickerPresenter)
        
        mediaPickerPresenter.view = viewController
        
        return viewController
    }
}
