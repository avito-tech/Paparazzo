import UIKit
import Marshroute

public protocol ScannerMarshrouteAssembly: AnyObject {
    func module(
        data: ScannerData,
        routerSeed: RouterSeed,
        configure: (ScannerModule) -> ())
        -> UIViewController
}

public extension ScannerMarshrouteAssembly {
    func module(
        data: ScannerData,
        routerSeed: RouterSeed,
        configure: (ScannerModule) -> ())
        -> UIViewController
    {
        return module(data: data, routerSeed: routerSeed, configure: configure)
    }
}

public protocol ScannerMarshrouteAssemblyFactory: AnyObject {
    func scannerAssembly() -> ScannerMarshrouteAssembly
}
