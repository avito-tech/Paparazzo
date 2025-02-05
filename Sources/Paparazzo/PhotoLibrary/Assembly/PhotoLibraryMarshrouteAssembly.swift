import UIKit
import Marshroute

public protocol PhotoLibraryMarshrouteAssembly: AnyObject {
    func module(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        routerSeed: RouterSeed,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryMarshrouteAssemblyFactory: AnyObject {
    func photoLibraryAssembly() -> PhotoLibraryMarshrouteAssembly
}
