import UIKit

public protocol ScannerAssembly: class {
    func module(
        data: ScannerData,
        overridenTheme: PaparazzoUITheme?,
        metalEnabled: Bool,
        configure: (ScannerModule) -> ())
        -> UIViewController
}

public protocol ScannerAssemblyFactory: class {
    func scannerAssembly() -> ScannerAssembly
}

public extension ScannerAssembly {
    func module(data: ScannerData, metalEnabled: Bool, configure: (ScannerModule) -> ()) -> UIViewController {
        return module(data: data, overridenTheme: nil, metalEnabled: metalEnabled, configure: configure)
    }
}
