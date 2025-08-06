import UIKit

public protocol PhotoLibraryV2Assembly: AnyObject {
    func module(
        data: PhotoLibraryV2Data,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isNewFlowPrototype: Bool,
        cameraType: MediaPickerCameraType,
        configure: (PhotoLibraryV2Module) -> (),
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> UIViewController
}

public protocol PhotoLibraryV2AssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2Assembly
}
