import UIKit

// TODO: rename module to StandaloneCamera
public protocol NewCameraAssembly: class {
    func module(
        selectedImagesStorage: SelectedImageStorage
    ) -> UIViewController
}

public protocol NewCameraAssemblyFactory: class {
    func newCameraAssembly() -> NewCameraAssembly
}
