import UIKit

protocol MedicalBookCameraAssembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        cameraStatusService: CameraStatusService,
        configure: (MedicalBookCameraModule) -> ()
    ) -> UIViewController
}

protocol MedicalBookCameraAssemblyFactory: AnyObject {
    func medicalBookCameraAssembly() -> MedicalBookCameraAssembly
}
