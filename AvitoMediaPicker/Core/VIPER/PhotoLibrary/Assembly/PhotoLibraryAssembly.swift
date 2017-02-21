import UIKit

public protocol PhotoLibraryAssembly: class {
    func module(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: (PhotoLibraryModule) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}
