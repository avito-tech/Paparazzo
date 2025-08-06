import UIKit

public protocol MediaPickerAssembly: AnyObject {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isPaparazzoImageUpdaingFixEnabled: Bool,
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
        isPaparazzoImageUpdaingFixEnabled: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isNewFlowPrototype: false,
            configure: configure
        )
    }
}
