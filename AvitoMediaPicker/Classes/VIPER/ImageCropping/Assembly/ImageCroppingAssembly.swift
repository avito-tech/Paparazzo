import UIKit
import Marshroute

protocol ImageCroppingAssembly: class {
    
    func viewController(
        photo photo: AnyObject, // TODO
        moduleOutput: ImageCroppingModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}