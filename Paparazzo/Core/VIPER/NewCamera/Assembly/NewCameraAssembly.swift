import UIKit

// TODO: rename module to StandaloneCamera
protocol NewCameraAssembly: class {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        shouldAllowFinishingWithNoPhotos: Bool,
        configure: (NewCameraModule) -> ()
    ) -> UIViewController
}

protocol NewCameraAssemblyFactory: class {
    func newCameraAssembly() -> NewCameraAssembly
}
