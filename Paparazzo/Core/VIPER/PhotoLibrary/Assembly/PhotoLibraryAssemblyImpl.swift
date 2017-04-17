import UIKit

public final class PhotoLibraryAssemblyImpl: PhotoLibraryAssembly {
    
    private let theme: PhotoLibraryUITheme
    
    init(theme: PhotoLibraryUITheme) {
        self.theme = theme
    }
    
    public func module(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configure: (PhotoLibraryModule) -> ())
        -> UIViewController
    {
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl()
        
        let interactor = PhotoLibraryInteractorImpl(
            selectedItems: selectedItems,
            maxSelectedItemsCount: maxSelectedItemsCount,
            photoLibraryItemsService: photoLibraryItemsService
        )
        
        let viewController = PhotoLibraryViewController()
        
        let router = PhotoLibraryUIKitRouter(viewController: viewController)
        
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
