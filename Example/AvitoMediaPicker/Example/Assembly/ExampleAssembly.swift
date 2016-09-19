import UIKit
import Marshroute

protocol ExampleAssembly: class {
    func viewController(routerSeed: RouterSeed) -> UIViewController
}
