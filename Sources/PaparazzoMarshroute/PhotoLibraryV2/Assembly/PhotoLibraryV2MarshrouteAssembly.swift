import UIKit
import Marshroute

public protocol PhotoLibraryV2MarshrouteAssembly: AnyObject {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        isPaparazzoCellDisablingFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
}

public extension PhotoLibraryV2MarshrouteAssembly {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isPaparazzoCellDisablingFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
    {
            return module(
                mediaPickerData: mediaPickerData,
                selectedItems: selectedItems,
                routerSeed: routerSeed,
                isNewFlowPrototype: false,
                isUsingCameraV3: false,
                isPaparazzoCellDisablingFixEnabled: isPaparazzoCellDisablingFixEnabled,
                configure: configure
            )
    }
}

public protocol PhotoLibraryV2MarshrouteAssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly
}
