import UIKit

protocol CameraV3Assembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        configure: (CameraV3Module) -> ()
    ) -> UIViewController
}

protocol CameraV3AssemblyFactory: AnyObject {
    func cameraV3Assembly() -> CameraV3Assembly
}
