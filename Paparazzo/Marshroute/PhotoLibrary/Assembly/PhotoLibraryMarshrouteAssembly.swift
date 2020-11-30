import UIKit
import Marshroute

public protocol PhotoLibraryMarshrouteAssembly: class {
    func module(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        showVideos: Bool,
        routerSeed: RouterSeed,
        configure: (PhotoLibraryModule) -> ())
        -> UIViewController
}

public protocol PhotoLibraryMarshrouteAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryMarshrouteAssembly
}
