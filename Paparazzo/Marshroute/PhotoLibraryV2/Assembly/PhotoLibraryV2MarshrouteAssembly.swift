import UIKit
import Marshroute

public protocol PhotoLibraryV2MarshrouteAssembly: AnyObject {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
}

public extension PhotoLibraryV2MarshrouteAssembly {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
    {
            return module(
                mediaPickerData: mediaPickerData,
                selectedItems: selectedItems,
                routerSeed: routerSeed,
                isNewFlowPrototype: false,
                configure: configure
            )
    }
}

public protocol PhotoLibraryV2MarshrouteAssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly
}
