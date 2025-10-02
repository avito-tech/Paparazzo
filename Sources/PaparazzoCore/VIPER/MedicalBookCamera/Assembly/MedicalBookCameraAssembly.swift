import UIKit

protocol MedicalBookCameraAssembly: AnyObject {
    func module(
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isRedesignedMediaPickerEnabled: Bool,
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
