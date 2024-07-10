import UIKit

final class PhotoLibraryUIKitRouter: BaseUIKitRouter, PhotoLibraryRouter {

    private let limitedAccessAlertFactory: LimitedAccessAlertFactory
    
    init(limitedAccessAlertFactory: LimitedAccessAlertFactory, viewController: UIViewController) {
        self.limitedAccessAlertFactory = limitedAccessAlertFactory
        super.init(viewController: viewController)
    }
    
    @available(iOS 14, *)
    func showLimitedAccessAlert() {
        present(limitedAccessAlertFactory.limitedAccessAlert(), animated: true)
    }
}
