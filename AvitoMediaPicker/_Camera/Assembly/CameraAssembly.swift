import UIKit
import AvitoNavigation

protocol CameraAssembly: class {
    func module(routerSeed routerSeed: RouterSeed)
        -> (viewController: UIViewController, moduleInput: CameraModuleInput)
    
    func module(routerSeed routerSeed: RouterSeed)
        -> UIViewController
}
