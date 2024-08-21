import UIKit

public protocol PhotoLibraryV2Assembly: AnyObject {
    func module(
        data: PhotoLibraryV2Data,
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        configure: (PhotoLibraryV2Module) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryV2AssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2Assembly
}
