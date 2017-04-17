import UIKit

public protocol PhotoLibraryAssembly: class {
    func module(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}
