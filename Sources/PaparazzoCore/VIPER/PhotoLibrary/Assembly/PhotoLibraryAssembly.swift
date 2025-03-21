import UIKit

public protocol PhotoLibraryAssembly: AnyObject {
    func module(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryAssemblyFactory: AnyObject {
    func photoLibraryAssembly() -> PhotoLibraryAssembly
}
