import Marshroute
import UIKit

public protocol MediaPickerMarshrouteAssembly: AnyObject {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        viewfinderOverlay: UIView?,
        routerSeed: RouterSeed,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController
}

public protocol MediaPickerMarshrouteAssemblyFactory: AnyObject {
    func mediaPickerAssembly() -> MediaPickerMarshrouteAssembly
}

public extension MediaPickerMarshrouteAssembly {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        routerSeed: RouterSeed,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController {
        return module(
            data: data,
            overridenTheme: overridenTheme,
            viewfinderOverlay: nil,
            routerSeed: routerSeed,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isNewFlowPrototype: isNewFlowPrototype,
            configure: configure
        )
    }
    
    func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            viewfinderOverlay: nil,
            routerSeed: routerSeed,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isNewFlowPrototype: isNewFlowPrototype,
            configure: configure
        )
    }
}
