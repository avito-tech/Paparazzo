import UIKit
import Marshroute

public protocol ImageCroppingAssembly: class {
    
    func viewController(
        photo photo: AnyObject, // TODO
        moduleOutput: ImageCroppingModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

public protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}