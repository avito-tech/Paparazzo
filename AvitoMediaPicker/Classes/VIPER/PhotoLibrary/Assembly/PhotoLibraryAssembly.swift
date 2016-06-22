import UIKit
import Marshroute

public protocol PhotoLibraryAssembly: class {
    func module(routerSeed routerSeed: RouterSeed) -> (UIViewController, PhotoLibraryModule)
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}