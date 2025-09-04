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
