import UIKit

class BaseUIKitRouter {
    
    // MARK: - Dependencies
    weak var viewController: UIViewController?
    
    // MARK: - Init
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - BaseUIKitRouter
    
    func focusOnCurrentModule() {
        guard let viewController = viewController else { return }
        
        if let navigationController = viewController.navigationController,
            viewController != navigationController.topViewController
        {
            navigationController.popToViewController(viewController, animated: true)
        }
        
        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissCurrentModule() {
        guard let viewController = viewController else { return }
        
        if let navigationController = viewController.navigationController {
            if let index = navigationController.viewControllers.index(of: viewController), index > 0 {
                let previousController = navigationController.viewControllers[index - 1]
                navigationController.popToViewController(previousController, animated: true)
            } else {
                navigationController.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        } else {
            viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
