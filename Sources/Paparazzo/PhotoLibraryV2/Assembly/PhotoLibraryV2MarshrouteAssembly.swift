import UIKit
import Marshroute

public protocol PhotoLibraryV2MarshrouteAssembly: AnyObject {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        cameraType: MediaPickerCameraType?,
        configure: (PhotoLibraryV2Module) -> (),
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> UIViewController
}

public extension PhotoLibraryV2MarshrouteAssembly {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        configure: (PhotoLibraryV2Module) -> ()
    ) -> UIViewController {
        module(
            mediaPickerData: mediaPickerData,
            selectedItems: selectedItems,
            routerSeed: routerSeed,
            isNewFlowPrototype: false,
            cameraType: nil,
            configure: configure,
            onCameraV3InitializationMeasurementStart: nil,
            onCameraV3InitializationMeasurementStop: nil,
            onCameraV3DrawingMeasurementStart: nil,
            onCameraV3DrawingMeasurementStop: nil
        )
    }
}

public protocol PhotoLibraryV2MarshrouteAssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly
}
