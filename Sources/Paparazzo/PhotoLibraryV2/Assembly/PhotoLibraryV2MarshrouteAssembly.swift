import UIKit
import Marshroute

public protocol PhotoLibraryV2MarshrouteAssembly: AnyObject {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> (),
        measureScreenInitialization: (() -> ())?,
        initializationMeasurementStop: (() -> ())?,
        drawingMeasurement: (() -> ())?
    ) -> UIViewController
}

public extension PhotoLibraryV2MarshrouteAssembly {
    func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> (),
        measureScreenInitialization: (() -> ())?,
        initializationMeasurementStop: (() -> ())?,
        drawingMeasurement: (() -> ())?
    ) -> UIViewController {
        module(
            mediaPickerData: mediaPickerData,
            selectedItems: selectedItems,
            routerSeed: routerSeed,
            isNewFlowPrototype: false,
            isUsingCameraV3: false,
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            configure: configure,
            measureScreenInitialization: measureScreenInitialization,
            initializationMeasurementStop: initializationMeasurementStop,
            drawingMeasurement: drawingMeasurement
        )
    }
}

public protocol PhotoLibraryV2MarshrouteAssemblyFactory: AnyObject {
    func photoLibraryV2Assembly() -> PhotoLibraryV2MarshrouteAssembly
}
