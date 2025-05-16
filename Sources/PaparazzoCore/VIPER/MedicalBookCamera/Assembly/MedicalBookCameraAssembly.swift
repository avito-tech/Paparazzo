import UIKit

protocol MedicalBookCameraAssembly: AnyObject {
    func module(
        isPhotoFetchLimitEnabled: Bool,
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
