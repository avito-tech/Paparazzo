import UIKit
import Marshroute

public protocol PhotoLibraryAssembly: class {
    
    func viewController(
        moduleOutput moduleOutput: PhotoLibraryModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}