import UIKit
import Marshroute

public protocol ScannerMarshrouteAssembly: class {
    func module(
        data: ScannerData,
        routerSeed: RouterSeed,
        isMetalEnabled: Bool,
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
        return module(data: data, routerSeed: routerSeed, isMetalEnabled: false, configure: configure)
    }
}

public protocol ScannerMarshrouteAssemblyFactory: class {
    func scannerAssembly() -> ScannerMarshrouteAssembly
}
