import UIKit
import Marshroute

public protocol PhotoLibraryV2MarshrouteAssembly: class {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        routerSeed: RouterSeed,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
}

public protocol PhotoLibraryV2MarshrouteAssemblyFactory: class {
    func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly
}
