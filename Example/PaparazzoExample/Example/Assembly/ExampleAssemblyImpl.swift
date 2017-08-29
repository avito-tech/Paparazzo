import UIKit
import Marshroute
import Paparazzo

final class ExampleAssemblyImpl: ExampleAssembly {
    
    private let mediaPickerAssemblyFactory: MarshrouteAssemblyFactory
    
    init(mediaPickerAssemblyFactory: MarshrouteAssemblyFactory) {
        self.mediaPickerAssemblyFactory = mediaPickerAssemblyFactory
    }
    
    // MARK: - ExampleAssembly
    
    func viewController(routerSeed: RouterSeed) -> UIViewController {
        
        let interactor = ExampleInteractorImpl()
        
        let router = ExampleRouterImpl(
            mediaPickerAssemblyFactory: mediaPickerAssemblyFactory,
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
