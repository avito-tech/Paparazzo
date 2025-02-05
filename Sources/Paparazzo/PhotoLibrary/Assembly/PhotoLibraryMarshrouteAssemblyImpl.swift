import UIKit
import Marshroute

public final class PhotoLibraryMarshrouteAssemblyImpl: BasePaparazzoAssembly, PhotoLibraryMarshrouteAssembly {
    
    public func module(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        routerSeed: RouterSeed,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController {
        
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl(
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            isPhotoFetchingByPageEnabled: isPhotoFetchingByPageEnabled
        )
        
        let interactor = PhotoLibraryInteractorImpl(
            selectedItems: selectedItems,
            maxSelectedItemsCount: maxSelectedItemsCount,
            photoLibraryItemsService: photoLibraryItemsService
        )
        
        let router = PhotoLibraryMarshrouteRouter(
            limitedAccessAlertFactory: LimitedAccessAlertFactoryImpl(), 
            routerSeed: routerSeed
        )
        
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
