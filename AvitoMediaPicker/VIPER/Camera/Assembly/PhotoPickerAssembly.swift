import UIKit
import Marshroute

public protocol PhotoPickerAssembly: class {
    func viewController(moduleOutput moduleOutput: PhotoPickerModuleOutput) -> UIViewController
}
