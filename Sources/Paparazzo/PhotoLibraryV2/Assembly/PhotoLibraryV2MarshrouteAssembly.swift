import UIKit
import Marshroute

public protocol PhotoLibraryV2MarshrouteAssembly: AnyObject {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        cameraType: MediaPickerCameraType,
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
        isNewFlowPrototype: Bool,
        configure: (PhotoLibraryV2Module) -> (),
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> UIViewController {
        module(
            mediaPickerData: mediaPickerData,
            selectedItems: selectedItems,
            routerSeed: routerSeed,
            isNewFlowPrototype: isNewFlowPrototype,
            cameraType: .cameraV3,
            configure: configure,
            onCameraV3InitializationMeasurementStart: onCameraV3InitializationMeasurementStart,
            onCameraV3InitializationMeasurementStop: onCameraV3InitializationMeasurementStop,
            onCameraV3DrawingMeasurementStart: onCameraV3DrawingMeasurementStart,
            onCameraV3DrawingMeasurementStop: onCameraV3DrawingMeasurementStop
        )
    }
}

public protocol PhotoLibraryV2MarshrouteAssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly
}
