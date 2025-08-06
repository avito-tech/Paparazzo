import UIKit

protocol CameraV3Assembly: AnyObject {
    func module(
        isPaparazzoImageUpdaingFixEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        configure: (CameraV3Module) -> (),
        onInitializationMeasurementStart: (() -> ())?,
        onInitializationMeasurementStop: (() -> ())?,
        onDrawingMeasurementStart: (() -> ())?,
        onDrawingMeasurementStop: (() -> ())?
    ) -> UIViewController
}

protocol CameraV3AssemblyFactory: AnyObject {
    func cameraV3Assembly() -> CameraV3Assembly
}
