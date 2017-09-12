import Marshroute
import UIKit

public protocol MediaPickerMarshrouteAssembly: class {
    func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerMarshrouteAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerMarshrouteAssembly
}
