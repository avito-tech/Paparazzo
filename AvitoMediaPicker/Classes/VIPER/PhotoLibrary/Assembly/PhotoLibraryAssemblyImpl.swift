import UIKit
import Marshroute

public final class PhotoLibraryAssemblyImpl: PhotoLibraryAssembly {
    
    public func viewController(
        maxItemsCount maxItemsCount: Int?,
        moduleOutput moduleOutput: PhotoLibraryModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController {
        
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl()
        
        let interactor = PhotoLibraryInteractorImpl(
            maxSelectedItemsCount: maxItemsCount,
            photoLibraryItemsService: photoLibraryItemsService
        )
        
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
