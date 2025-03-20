import Marshroute
import UIKit

// TODO: rename module to StandaloneCamera
protocol NewCameraMarshrouteAssembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        shouldAllowFinishingWithNoPhotos: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        routerSeed: RouterSeed,
        configure: (NewCameraModule) -> ()
    ) -> UIViewController
}

protocol NewCameraMarshrouteAssemblyFactory: AnyObject {
    func newCameraAssembly() -> NewCameraMarshrouteAssembly
}
