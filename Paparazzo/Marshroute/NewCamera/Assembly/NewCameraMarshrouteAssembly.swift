import Marshroute
import UIKit

// TODO: rename module to StandaloneCamera
public protocol NewCameraMarshrouteAssembly: class {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        routerSeed: RouterSeed
    ) -> UIViewController
}

public protocol NewCameraMarshrouteAssemblyFactory: class {
    func newCameraAssembly() -> NewCameraMarshrouteAssembly
}
