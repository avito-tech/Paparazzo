import UIKit
import Marshroute

public final class ImageCroppingAssemblyImpl: ImageCroppingAssembly {
    
    public func viewController(
        photo photo: AnyObject,
        moduleOutput: ImageCroppingModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController {

        let interactor = ImageCroppingInteractorImpl()

        let router = ImageCroppingRouterImpl(routerSeed: routerSeed)

        let presenter = ImageCroppingPresenter(
            interactor: interactor,
            router: router
        )

        let viewController = ImageCroppingViewController()
        viewController.addDisposable(presenter)

        presenter.view = viewController
        presenter.moduleOutput = moduleOutput

        return viewController
    }
}
