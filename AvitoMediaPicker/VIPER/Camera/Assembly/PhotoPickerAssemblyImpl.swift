import UIKit
import Marshroute

final class PhotoPickerAssemblyImpl: PhotoPickerAssembly {
    
    // MARK: - MediaPickerAssembly
    
    func viewController(moduleOutput moduleOutput: PhotoPickerModuleOutput) -> UIViewController {

        let imageResizingService = ImageResizingServiceImpl()
        let cameraService = CameraServiceImpl(imageResizingService: imageResizingService)
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl(),
            imageResizingService: imageResizingService
        )

        let router = CameraRouterImpl()
        
        let presenter = CameraPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = CameraViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        presenter.moduleOutput = moduleOutput
        
        return viewController
    }
}
