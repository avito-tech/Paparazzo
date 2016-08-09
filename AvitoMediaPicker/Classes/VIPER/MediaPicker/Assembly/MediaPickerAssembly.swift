import UIKit
import Marshroute

public protocol MediaPickerAssembly: class {
    
    func module(
        items items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropEnabled: Bool,
        routerSeed: RouterSeed,
        configuration: MediaPickerModule -> ()
    ) -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}
