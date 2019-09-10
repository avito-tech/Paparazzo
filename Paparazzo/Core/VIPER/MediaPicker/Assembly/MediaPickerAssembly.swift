import UIKit

public protocol MediaPickerAssembly: class {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isMetalEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}

public extension MediaPickerAssembly {
    func module(data: MediaPickerData, isMetalEnabled: Bool, configure: (MediaPickerModule) -> ()) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            isMetalEnabled: isMetalEnabled,
            isNewFlowPrototype: false,
            configure: configure
        )
    }
    
    func module(data: MediaPickerData, configure: (MediaPickerModule) -> ()) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            isMetalEnabled: false,
            isNewFlowPrototype: false,
            configure: configure
        )
    }
}
