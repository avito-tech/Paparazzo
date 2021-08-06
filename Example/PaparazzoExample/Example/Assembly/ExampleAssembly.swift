import UIKit
import Marshroute

protocol ExampleAssembly: AnyObject {
    func viewController(routerSeed: RouterSeed) -> UIViewController
}
