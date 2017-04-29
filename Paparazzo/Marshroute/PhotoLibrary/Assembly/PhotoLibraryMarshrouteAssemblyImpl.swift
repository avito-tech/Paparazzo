import UIKit
import Marshroute

public final class PhotoLibraryMarshrouteAssemblyImpl: BasePaparazzoAssembly, PhotoLibraryMarshrouteAssembly {
    
    public func module(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        routerSeed: RouterSeed,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController {
        
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl()
        
        let interactor = PhotoLibraryInteractorImpl(
            selectedItems: selectedItems,
            maxSelectedItemsCount: maxSelectedItemsCount,
            photoLibraryItemsService: photoLibraryItemsService
        )
        
        let router = PhotoLibraryMarshrouteRouter(routerSeed: routerSeed)
        
        let presenter = PhotoLibraryPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = PhotoLibraryViewController()
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
