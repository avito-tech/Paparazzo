import UIKit

public final class PhotoLibraryAssemblyImpl: BasePaparazzoAssembly, PhotoLibraryAssembly {
    
    public func module(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ())
        -> UIViewController
    {
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl(
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled
        )
        
        let interactor = PhotoLibraryInteractorImpl(
            selectedItems: data.selectedItems,
            maxSelectedItemsCount: data.maxSelectedItemsCount,
            photoLibraryItemsService: photoLibraryItemsService
        )
        
        let viewController = PhotoLibraryViewController()
        
        let router = PhotoLibraryUIKitRouter(
            limitedAccessAlertFactory: LimitedAccessAlertFactoryImpl(), 
            viewController: viewController
        )
        
        let presenter = PhotoLibraryPresenter(
            interactor: interactor,
            router: router
        )
        
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
