import Marshroute
import UIKit

final class PhotoLibraryMarshrouteRouter: BaseRouter, PhotoLibraryRouter {

    private let limitedAccessAlertFactory: LimitedAccessAlertFactory
    
    init(limitedAccessAlertFactory: LimitedAccessAlertFactory, routerSeed: RouterSeed) {
        self.limitedAccessAlertFactory = limitedAccessAlertFactory
        super.init(routerSeed: routerSeed)
    }

    @available(iOS 14, *)
    func showLimitedAccessAlert() {
        presentModalViewControllerDerivedFrom { _ in
            return limitedAccessAlertFactory.limitedAccessAlert()
        }
    }
}
