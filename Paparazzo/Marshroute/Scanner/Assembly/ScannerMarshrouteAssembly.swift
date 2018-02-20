import UIKit
import Marshroute

public protocol ScannerMarshrouteAssembly: class {
    func module(
        data: ScannerData,
        routerSeed: RouterSeed,
        configure: (ScannerModule) -> ())
        -> UIViewController
}

public protocol ScannerMarshrouteAssemblyFactory: class {
    func scannerAssembly() -> ScannerMarshrouteAssembly
}
