import UIKit
import Marshroute

public protocol PhotoLibraryAssembly: class {
    func module(
        maxSelectedItemsCount maxSelectedItemsCount: Int?,
        routerSeed routerSeed: RouterSeed
    ) -> (UIViewController, PhotoLibraryModule)
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}