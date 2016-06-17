import UIKit
import Marshroute

protocol PhotoLibraryAssembly: class {
    
    func viewController(
        maxItemsCount maxItemsCount: Int?,
        moduleOutput moduleOutput: PhotoLibraryModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController
}

protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}