import UIKit
import Marshroute
import AvitoDesignKit

protocol ImageCroppingAssembly: class {
    
    func viewController(
        image image: ImageSource,
        routerSeed: RouterSeed,
        configuration: ImageCroppingModule -> ()
    ) -> UIViewController
}

protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}