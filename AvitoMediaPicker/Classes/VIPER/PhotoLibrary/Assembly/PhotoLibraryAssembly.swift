import UIKit
import Marshroute

public protocol PhotoLibraryAssembly: class {
    func module(
        maxSelectedItemsCount maxSelectedItemsCount: Int?,
        routerSeed routerSeed: RouterSeed,
        configuration: PhotoLibraryModule -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}