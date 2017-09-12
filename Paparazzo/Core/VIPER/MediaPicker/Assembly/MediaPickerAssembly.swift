import UIKit

public protocol MediaPickerAssembly: class {
    func module(
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}
