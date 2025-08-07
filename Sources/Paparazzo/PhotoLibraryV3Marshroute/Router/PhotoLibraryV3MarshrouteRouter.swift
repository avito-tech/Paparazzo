import Marshroute
import UIKit

final class PhotoLibraryV3MarshrouteRouter: BaseRouter, PhotoLibraryV3Router {
    typealias AssemblyFactory =
    MediaPickerMarshrouteAssemblyFactory
    & LimitedAccessAlertFactory
    & CameraV3MarshrouteAssemblyFactory
    & MedicalBookCameraMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    private let cameraService: CameraService
    private let cameraStatusService: CameraStatusService
    
    init(
        assemblyFactory: AssemblyFactory,
        cameraService: CameraService,
        cameraStatusService: CameraStatusService,
        routerSeed: RouterSeed
    ) {
        self.assemblyFactory = assemblyFactory
        self.cameraService = cameraService
        self.cameraStatusService = cameraStatusService
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - PhotoLibraryV3Router
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
    {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                data: data,
                overridenTheme: overridenTheme,
                routerSeed: routerSeed,
                isNewFlowPrototype: isNewFlowPrototype, 
                configure: configure
            )
        }
    }
    
    func showCameraV3(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (CameraV3Module) -> (),
        onInitializationMeasurementStart: (() -> ())?,
        onInitializationMeasurementStop: (() -> ())?,
        onDrawingMeasurementStart: (() -> ())?,
        onDrawingMeasurementStop: (() -> ())?
    ) {
        presentModalViewControllerDerivedFrom { routerSeed in
            assemblyFactory.cameraV3Assembly().module(
                selectedImagesStorage: selectedImagesStorage,
                mediaPickerData: mediaPickerData,
                cameraService: cameraService,
                routerSeed: routerSeed, 
                configure: configure,
                onInitializationMeasurementStart: onInitializationMeasurementStart,
                onInitializationMeasurementStop: onInitializationMeasurementStop,
                onDrawingMeasurementStart: onDrawingMeasurementStart, 
                onDrawingMeasurementStop: onDrawingMeasurementStop
            )
        }
    }
    
    func showMedicalBookCamera(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (MedicalBookCameraModule) -> ()
    ) {
        presentModalViewControllerDerivedFrom { routerSeed in
            assemblyFactory.medicalBookCameraAssembly().module(
                selectedImagesStorage: selectedImagesStorage,
                mediaPickerData: mediaPickerData,
                cameraService: cameraService,
                cameraStatusService: cameraStatusService,
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
    
    @available(iOS 14, *)
    func showLimitedAccessAlert() {
        presentModalViewControllerDerivedFrom { _ in
            return assemblyFactory.limitedAccessAlert()
        }
    }
}
