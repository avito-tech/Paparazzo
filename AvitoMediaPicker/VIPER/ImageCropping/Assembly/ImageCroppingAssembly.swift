import UIKit

public protocol ImageCroppingAssembly: class {
    
    func viewController(
        photo photo: AnyObject, // TODO
        moduleOutput: ImageCroppingModuleOutput
    ) -> UIViewController
}

public protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}