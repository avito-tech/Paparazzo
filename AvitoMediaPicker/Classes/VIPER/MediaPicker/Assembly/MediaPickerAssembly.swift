import UIKit
import Marshroute

public protocol MediaPickerAssembly: class {
    
    func module(
        maxItemsCount maxItemsCount: Int?,
        routerSeed: RouterSeed
    ) -> (UIViewController, MediaPickerModule)
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}
