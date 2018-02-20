import UIKit

public protocol ScannerAssembly: class {
    func module(
        data: ScannerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (ScannerModule) -> ())
        -> UIViewController
}

public protocol ScannerAssemblyFactory: class {
    func scannerAssembly() -> ScannerAssembly
}

public extension ScannerAssembly {
    func module(data: ScannerData, configure: (ScannerModule) -> ()) -> UIViewController {
        return module(data: data, overridenTheme: nil, configure: configure)
    }
}
