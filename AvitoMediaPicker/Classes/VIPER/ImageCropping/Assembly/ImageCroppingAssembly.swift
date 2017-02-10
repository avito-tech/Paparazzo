import UIKit
import ImageSource
import Marshroute

protocol ImageCroppingAssembly: class {
    
    func viewController(
        image: ImageSource,
        canvasSize: CGSize,
        routerSeed: RouterSeed,
        configuration: (ImageCroppingModule) -> ()
    ) -> UIViewController
}

protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}
