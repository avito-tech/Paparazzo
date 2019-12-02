import UIKit
import Marshroute

public protocol ScannerMarshrouteAssembly: class {
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

public protocol ScannerMarshrouteAssemblyFactory: class {
    func scannerAssembly() -> ScannerMarshrouteAssembly
}
