import UIKit

public protocol PhotoLibraryAssembly: class {
    func module(
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: class {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}
