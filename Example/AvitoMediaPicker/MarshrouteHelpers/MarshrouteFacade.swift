import Marshroute

final class MarshrouteFacade {
    
    func navigationController(
        _ navigationController: UINavigationController? = nil,
        withRootViewControllerDerivedFrom deriveViewController: (RouterSeed) -> UIViewController)
        -> UIViewController
    {
        let marshrouteSetupService = MarshrouteSetupServiceImpl()
        
        let marshrouteStack = marshrouteSetupService.marshrouteStack()
        
        let transitionId = marshrouteStack.transitionIdGenerator.generateNewTransitionId()
        
        let navigationController = navigationController ?? marshrouteStack.routerControllersProvider.navigationController()
        
        let navigationTransitionsHandler = marshrouteStack.transitionsHandlersProvider.navigationTransitionsHandler(
            navigationController: navigationController
        )
        
        let routerSeed = RouterSeed(
            transitionsHandlerBox: .init(animatingTransitionsHandler: navigationTransitionsHandler),
            transitionId: transitionId,
            presentingTransitionsHandler: nil,
            transitionsHandlersProvider: marshrouteStack.transitionsHandlersProvider,
            transitionIdGenerator: marshrouteStack.transitionIdGenerator,
            controllersProvider: marshrouteStack.routerControllersProvider
        )
        
        let viewController = deriveViewController(routerSeed)
        
        let resetContext = ResettingTransitionContext(
            settingRootViewController: viewController,
            forNavigationController: navigationController,
            animatingTransitionsHandler: navigationTransitionsHandler,
            animator: SetNavigationTransitionsAnimator(),
            transitionId: transitionId
        )
        
        navigationTransitionsHandler.resetWithTransition(
            context: resetContext
        )
        
        return navigationController
    }
}
