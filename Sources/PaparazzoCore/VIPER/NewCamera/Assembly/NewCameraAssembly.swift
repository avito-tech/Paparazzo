import UIKit

// TODO: rename module to StandaloneCamera
protocol NewCameraAssembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        shouldAllowFinishingWithNoPhotos: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (NewCameraModule) -> ()
    ) -> UIViewController
}

protocol NewCameraAssemblyFactory: AnyObject {
    func newCameraAssembly() -> NewCameraAssembly
}
