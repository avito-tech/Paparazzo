import UIKit
import Marshroute

public final class PhotoLibraryAssemblyImpl: PhotoLibraryAssembly {
    
    private let theme: PhotoLibraryUITheme
    
    init(theme: PhotoLibraryUITheme) {
        self.theme = theme
    }
    
    public func viewController(
        maxItemsCount maxItemsCount: Int?,
        moduleOutput: PhotoLibraryModuleOutput,
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
        viewController.setTheme(theme)
        
        presenter.view = viewController
        presenter.moduleOutput = moduleOutput
        
        return viewController
    }
}
