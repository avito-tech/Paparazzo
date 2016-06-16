import UIKit
import Marshroute

public protocol MediaPickerAssembly: class {
    
    func viewController(
        moduleOutput moduleOutput: MediaPickerModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

public protocol MediaPickerAssemblyFactory: class {
    func mediaPickerAssembly() -> MediaPickerAssembly
}
