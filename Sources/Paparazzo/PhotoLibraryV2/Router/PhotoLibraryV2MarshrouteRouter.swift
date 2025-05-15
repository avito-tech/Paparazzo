import Marshroute
import UIKit

final class PhotoLibraryV2MarshrouteRouter: BaseRouter, PhotoLibraryV2Router {
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
    
    // MARK: - PhotoLibraryV2Router
    func showMediaPicker(
        isPhotoFetchLimitEnabled: Bool,
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
    {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
                data: data,
                overridenTheme: overridenTheme,
                routerSeed: routerSeed,
                isNewFlowPrototype: isNewFlowPrototype, 
                configure: configure
            )
        }
    }
    
    func showCameraV3(
        isPhotoFetchLimitEnabled: Bool,
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
                isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
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
        isPhotoFetchLimitEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (MedicalBookCameraModule) -> ()
    ) {
        presentModalViewControllerDerivedFrom { routerSeed in
            assemblyFactory.medicalBookCameraAssembly().module(
                isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
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
