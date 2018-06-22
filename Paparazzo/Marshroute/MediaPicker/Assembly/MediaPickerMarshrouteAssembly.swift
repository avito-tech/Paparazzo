import Marshroute
import UIKit

public protocol MediaPickerMarshrouteAssembly: class {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        routerSeed: RouterSeed,
        metalEnabled: Bool,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerMarshrouteAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerMarshrouteAssembly
}

public extension MediaPickerMarshrouteAssembly {
    func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        metalEnabled: Bool,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        return module(data: data, overridenTheme: nil, routerSeed: routerSeed, metalEnabled: metalEnabled, configure: configure)
    }
    
    func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        return module(data: data, overridenTheme: nil, routerSeed: routerSeed, metalEnabled: false, configure: configure)
    }
}
