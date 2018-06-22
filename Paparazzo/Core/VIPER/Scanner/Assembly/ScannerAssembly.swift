import UIKit

public protocol ScannerAssembly: class {
    func module(
        data: ScannerData,
        overridenTheme: PaparazzoUITheme?,
        isMetalEnabled: Bool,
        configure: (ScannerModule) -> ())
        -> UIViewController
}

public protocol ScannerAssemblyFactory: class {
    func scannerAssembly() -> ScannerAssembly
}

public extension ScannerAssembly {
    func module(data: ScannerData, isMetalEnabled: Bool, configure: (ScannerModule) -> ()) -> UIViewController {
        return module(data: data, overridenTheme: nil, isMetalEnabled: isMetalEnabled, configure: configure)
    }
}
