import UIKit
import Marshroute

public protocol PhotoPickerAssembly: class {
    
    func viewController(
        moduleOutput moduleOutput: PhotoPickerModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

public protocol PhotoPickerAssemblyFactory: class {
    func photoPickerAssembly() -> PhotoPickerAssembly
}
