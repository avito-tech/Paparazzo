import UIKit

public protocol PhotoLibraryV2Assembly: class {
    func module(
        data: PhotoLibraryV2Data,
        isMetalEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (PhotoLibraryV2Module) -> ()
    ) -> UIViewController
}

public protocol PhotoLibraryV2AssemblyFactory: class {
    func photoLibraryV2Assembly() -> PhotoLibraryV2Assembly
}
