import UIKit
import AvitoNavigation

final class CameraAssemblyImpl: BaseAvitoAssembly, CameraAssembly {
    // MARK: - CameraAssembly
    func module(routerSeed routerSeed: RouterSeed)
        -> (viewController: UIViewController, moduleInput: CameraModuleInput)
    {
        let interactor = CameraInteractorImpl()
        
        let router = CameraRouterImpl(
            routerSeed: routerSeed
        )
        
        let presenter = CameraPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = CameraViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        return (viewController, presenter)
    }
    
    func module(routerSeed routerSeed: RouterSeed)
        -> UIViewController
    {
        let interactor = CameraInteractorImpl()
        
        let router = CameraRouterImpl(
            routerSeed: routerSeed
        )
        
        let presenter = CameraPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = CameraViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        return viewController
    }
}
