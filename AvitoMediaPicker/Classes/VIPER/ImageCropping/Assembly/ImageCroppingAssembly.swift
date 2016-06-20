import UIKit
import Marshroute

protocol ImageCroppingAssembly: class {
    
    func viewController(
        photo photo: MediaPickerItem,
        moduleOutput: ImageCroppingModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}