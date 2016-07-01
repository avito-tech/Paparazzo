import UIKit
import Marshroute

protocol ImageCroppingAssembly: class {
    
    func viewController(
        photo photo: MediaPickerItem,
        routerSeed: RouterSeed,
        configuration: ImageCroppingModule -> ()
    ) -> UIViewController
}

protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}