import UIKit
import Marshroute

final class ExampleAssemblyImpl: ExampleAssembly {
    
    // MARK: - ExampleAssembly
    
    func viewController(routerSeed routerSeed: RouterSeed) -> UIViewController {
        
        let interactor = ExampleInteractorImpl()
        
        let router = ExampleRouterImpl(
            routerSeed: routerSeed
        )
        
        let presenter = ExamplePresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = ExampleViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        return viewController
    }
}
