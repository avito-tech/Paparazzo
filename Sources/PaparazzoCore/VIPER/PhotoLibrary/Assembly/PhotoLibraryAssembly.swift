import UIKit

public protocol PhotoLibraryAssembly: AnyObject {
    func module(
        isPhotoFetchLimitEnabled: Bool,
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: AnyObject {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}
