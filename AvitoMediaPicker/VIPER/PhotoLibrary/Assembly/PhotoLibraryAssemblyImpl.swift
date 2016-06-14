import UIKit
import Marshroute

public final class PhotoLibraryAssemblyImpl: PhotoLibraryAssembly {
    
    public func viewController(
        moduleOutput moduleOutput: PhotoLibraryModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController {
        
        let interactor = PhotoLibraryInteractorImpl()
        
        let router = PhotoLibraryRouterImpl(routerSeed: routerSeed)
        
        let presenter = PhotoLibraryPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = PhotoLibraryViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        presenter.moduleOutput = moduleOutput
        
        return viewController
    }
}
