import UIKit

public protocol MediaPickerAssembly: class {
    func module(
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly(theme: PaparazzoUITheme?) -> MediaPickerAssembly
}

public extension MediaPickerAssemblyFactory {
    func mediaPickerAssembly() -> MediaPickerAssembly {
        return mediaPickerAssembly(theme: nil)
    }
}
