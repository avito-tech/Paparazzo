import UIKit

final class PhotoLibraryV2UIKitRouter: BaseUIKitRouter, PhotoLibraryV2Router {
    
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    & LimitedAccessAlertFactory
    & CameraV3AssemblyFactory
    & MedicalBookCameraAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    private let cameraService: CameraService
    private let cameraStatusService: CameraStatusService
    
    init(
        assemblyFactory: AssemblyFactory,
        cameraService: CameraService,
        cameraStatusService: CameraStatusService,
        viewController: UIViewController
    ) {
        self.assemblyFactory = assemblyFactory
        self.cameraService = cameraService
        self.cameraStatusService = cameraStatusService
        super.init(viewController: viewController)
    }
    
    // MARK: - PhotoLibraryV2Router
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
    {
        let assembly = assemblyFactory.mediaPickerAssembly()
        
        let viewController = assembly.module(
            data: data,
            overridenTheme: overridenTheme,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isNewFlowPrototype: isNewFlowPrototype,
            configure: configure
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func showCameraV3(
        isPaparazzoImageUpdaingFixEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (CameraV3Module) -> (),
        onInitializationMeasurementStart: (() -> ())?,
        onInitializationMeasurementStop: (() -> ())?,
        onDrawingMeasurementStart: (() -> ())?,
        onDrawingMeasurementStop: (() -> ())?
    ) {
        let assembly = assemblyFactory.cameraV3Assembly()
        let viewController = assembly.module(
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            selectedImagesStorage: selectedImagesStorage,
            mediaPickerData: mediaPickerData,
            cameraService: cameraService, 
            configure: configure,
            onInitializationMeasurementStart: onInitializationMeasurementStart,
            onInitializationMeasurementStop: onInitializationMeasurementStop,
            onDrawingMeasurementStart: onDrawingMeasurementStart, 
            onDrawingMeasurementStop: onDrawingMeasurementStop
        )
        present(viewController, animated: true)
    }
    
    func showMedicalBookCamera(
        isPaparazzoImageUpdaingFixEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (MedicalBookCameraModule) -> ()
    ) {
        let assembly = assemblyFactory.medicalBookCameraAssembly()
        let viewController = assembly.module(
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            selectedImagesStorage: selectedImagesStorage,
            mediaPickerData: mediaPickerData,
            cameraService: cameraService,
            cameraStatusService: cameraStatusService,
            configure: configure
        )
        present(viewController, animated: true)
    }
    
    @available(iOS 14, *)
    func showLimitedAccessAlert() {
        present(assemblyFactory.limitedAccessAlert(), animated: true)
    }
}
