import UIKit

public protocol MediaPickerAssembly: class {
    func module(
        settings: MediaPickerSettings,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}
