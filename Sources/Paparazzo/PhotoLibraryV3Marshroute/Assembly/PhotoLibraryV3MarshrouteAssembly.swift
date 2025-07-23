import UIKit
import Marshroute

public protocol PhotoLibraryV3MarshrouteAssembly: AnyObject {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryV3Item],
        routerSeed: RouterSeed,
        cameraType: MediaPickerCameraType,
        configure: (PhotoLibraryV3Module) -> (),
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> UIViewController
}

public protocol PhotoLibraryV3MarshrouteAssemblyFactory: AnyObject {
    func photoLibraryV3Assembly() -> PhotoLibraryV3MarshrouteAssembly
}
