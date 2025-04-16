import UIKit

public protocol MediaPickerAssembly: AnyObject {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController
}

public protocol MediaPickerAssemblyFactory: AnyObject {
    func mediaPickerAssembly() -> MediaPickerAssembly
}

public extension MediaPickerAssembly {
    func module(
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            isNewFlowPrototype: false,
            configure: configure
        )
    }
}
