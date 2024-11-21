import UIKit

public protocol PhotoLibraryV2Assembly: AnyObject {
    func module(
        data: PhotoLibraryV2Data,
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> (),
        cameraV3MeasureInitialization: (() -> ())?,
        cameraV3InitializationMeasurementStop: (() -> ())?,
        cameraV3DrawingMeasurement: (() -> ())?
    ) -> UIViewController
}

public protocol PhotoLibraryV2AssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2Assembly
}
