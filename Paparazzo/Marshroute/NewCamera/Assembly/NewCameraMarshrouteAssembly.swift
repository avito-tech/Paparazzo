import Marshroute
import UIKit

// TODO: rename module to StandaloneCamera
protocol NewCameraMarshrouteAssembly: class {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        routerSeed: RouterSeed,
        configure: (NewCameraModule) -> ()
    ) -> UIViewController
}

protocol NewCameraMarshrouteAssemblyFactory: class {
    func newCameraAssembly() -> NewCameraMarshrouteAssembly
}
