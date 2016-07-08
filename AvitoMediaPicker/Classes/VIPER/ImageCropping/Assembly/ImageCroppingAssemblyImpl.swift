import UIKit
import Marshroute

public final class ImageCroppingAssemblyImpl: ImageCroppingAssembly {
    
    private let theme: ImageCroppingUITheme
    
    init(theme: ImageCroppingUITheme) {
        self.theme = theme
    }
    
    public func viewController(
        photo photo: MediaPickerItem,
        routerSeed: RouterSeed,
        configuration: ImageCroppingModule -> ()
    ) -> UIViewController {

        let interactor = ImageCroppingInteractorImpl()

        let router = ImageCroppingRouterImpl(routerSeed: routerSeed)

        let presenter = ImageCroppingPresenter(
            interactor: interactor,
            router: router
        )

        let viewController = ImageCroppingViewController()
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)

        presenter.view = viewController
        
        configuration(presenter)

        return viewController
    }
}
