import UIKit

public protocol MediaPickerAssembly: class {
    func module(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropEnabled: Bool,
        cropCanvasSize: CGSize,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}
