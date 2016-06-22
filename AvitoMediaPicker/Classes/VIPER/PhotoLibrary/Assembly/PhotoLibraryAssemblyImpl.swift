import UIKit
import Marshroute

public final class PhotoLibraryAssemblyImpl: PhotoLibraryAssembly {
    
    private let theme: PhotoLibraryUITheme
    
    init(theme: PhotoLibraryUITheme) {
        self.theme = theme
    }
    
    public func module(routerSeed routerSeed: RouterSeed) -> (UIViewController, PhotoLibraryModule) {
        
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl()
        
        let interactor = PhotoLibraryInteractorImpl(
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
        
        return (viewController, presenter)
    }
}
