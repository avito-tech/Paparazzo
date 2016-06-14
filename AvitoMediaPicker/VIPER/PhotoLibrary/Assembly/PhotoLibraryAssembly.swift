import UIKit
import Marshroute

public protocol PhotoLibraryAssembly: class {
    func viewController(moduleOutput moduleOutput: PhotoLibraryModuleOutput) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}