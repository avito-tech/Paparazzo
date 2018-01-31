import UIKit

public protocol MediaPickerAssembly: class {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}

public extension MediaPickerAssembly {
    func module(data: MediaPickerData, configure: (MediaPickerModule) -> ()) -> UIViewController {
        return module(data: data, overridenTheme: nil, configure: configure)
    }
}
