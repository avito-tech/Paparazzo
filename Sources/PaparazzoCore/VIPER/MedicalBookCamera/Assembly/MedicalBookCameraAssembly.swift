import UIKit

protocol MedicalBookCameraAssembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        configure: (MedicalBookCameraModule) -> ()
    ) -> UIViewController
}

protocol MedicalBookCameraAssemblyFactory: AnyObject {
    func medicalBookCameraAssembly() -> MedicalBookCameraAssembly
}
