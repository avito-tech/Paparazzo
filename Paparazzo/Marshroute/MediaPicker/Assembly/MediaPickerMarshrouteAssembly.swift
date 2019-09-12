import Marshroute
import UIKit

public protocol MediaPickerMarshrouteAssembly: class {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        routerSeed: RouterSeed,
        isMetalEnabled: Bool,
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
        isMetalEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        return module(
            data: data,
            overridenTheme: nil,
            routerSeed: routerSeed,
            isMetalEnabled: isMetalEnabled,
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
            isMetalEnabled: false,
            isNewFlowPrototype: false,
            configure: configure
        )
    }
}
