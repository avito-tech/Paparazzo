import UIKit

public protocol PhotoLibraryV3Assembly: AnyObject {
    func module(
        data: PhotoLibraryV3Data,
        cameraType: MediaPickerCameraType,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        configure: (PhotoLibraryV3Module) -> (),
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> UIViewController
}

public protocol PhotoLibraryV3AssemblyFactory: AnyObject {
    func photoLibraryV3Assembly() -> PhotoLibraryV3Assembly
}
