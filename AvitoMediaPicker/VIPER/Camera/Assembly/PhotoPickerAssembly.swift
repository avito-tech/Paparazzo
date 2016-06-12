import UIKit
import Marshroute

protocol PhotoPickerAssembly: class {
    func viewController(moduleOutput moduleOutput: PhotoPickerModuleOutput) -> UIViewController
}
