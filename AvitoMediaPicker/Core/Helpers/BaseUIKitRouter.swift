import UIKit

class BaseUIKitRouter {
    
    // MARK: - Dependencies
    let viewController: UIViewController
    
    // MARK: - Init
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - BaseUIKitRouter
    
    func focusOnCurrentModule() {
        if let navigationController = viewController.navigationController {
            if viewController != navigationController.topViewController {
                navigationController.popToViewController(viewController, animated: true)
            } else {
                viewController.dismiss(animated: true, completion: nil)
            }
        } else {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissCurrentModule() {
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
