import Marshroute
import UIKit

final class NewCameraMarshrouteAssemblyImpl:
    BasePaparazzoAssembly,
    NewCameraMarshrouteAssembly
{
    // MARK: - NewCameraAssembly
    func module(
        selectedImagesStorage: SelectedImageStorage,
        routerSeed: RouterSeed,
        configure: (NewCameraModule) -> ())
        -> UIViewController
    {
        let interactor = NewCameraInteractorImpl()
        
        let viewController = NewCameraViewController(
            selectedImagesStorage: selectedImagesStorage,
            cameraService: serviceFactory.cameraService(initialActiveCameraType: .back)
        )
        
        let router = NewCameraRouterImpl(viewController: viewController)
        
        let presenter = NewCameraPresenter(
            interactor: interactor,
            router: router
        )
        
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
