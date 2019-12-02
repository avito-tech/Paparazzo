import Marshroute
import UIKit

public protocol MediaPickerMarshrouteAssembly: class {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
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
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        return module(
            data: data,
            overridenTheme: nil,
            routerSeed: routerSeed,
            isNewFlowPrototype: isNewFlowPrototype,
            configure: configure
        )
    }
    
    func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        return module(
            data: data,
            overridenTheme: nil,
            routerSeed: routerSeed,
            isNewFlowPrototype: false,
            configure: configure
        )
    }
}
