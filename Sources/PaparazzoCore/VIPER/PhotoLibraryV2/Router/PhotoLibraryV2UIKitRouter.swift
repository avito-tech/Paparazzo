import UIKit

final class PhotoLibraryV2UIKitRouter: BaseUIKitRouter, PhotoLibraryV2Router {
    
    typealias AssemblyFactory = MediaPickerAssemblyFactory & NewCameraAssemblyFactory & LimitedAccessAlertFactory & CameraV3AssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    private let cameraService: CameraService
    
    init(assemblyFactory: AssemblyFactory, cameraService: CameraService, viewController: UIViewController) {
        self.assemblyFactory = assemblyFactory
        self.cameraService = cameraService
        super.init(viewController: viewController)
    }
    
    // MARK: - PhotoLibraryV2Router
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (MediaPickerModule) -> ())
    {
        let assembly = assemblyFactory.mediaPickerAssembly()
        
        let viewController = assembly.module(
            data: data,
            overridenTheme: overridenTheme,
            isNewFlowPrototype: isNewFlowPrototype,
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            configure: configure
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func showNewCamera(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        shouldAllowFinishingWithNoPhotos: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (NewCameraModule) -> ())
    {
        let assembly = assemblyFactory.newCameraAssembly()
        
        let viewController = assembly.module(
            selectedImagesStorage: selectedImagesStorage,
            mediaPickerData: mediaPickerData,
            cameraService: cameraService,
            shouldAllowFinishingWithNoPhotos: shouldAllowFinishingWithNoPhotos, 
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            configure: configure
        )
        
        present(viewController, animated: true)
    }
    
    func showCameraV3(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (CameraV3Module) -> (),
        onInitializationMeasurementStart: (() -> ())?,
        onInitializationMeasurementStop: (() -> ())?,
        onDrawingMeasurementStart: (() -> ())?
    ) {
        let assembly = assemblyFactory.cameraV3Assembly()
        let viewController = assembly.module(
            selectedImagesStorage: selectedImagesStorage,
            mediaPickerData: mediaPickerData,
            cameraService: cameraService, 
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            configure: configure,
            onInitializationMeasurementStart: onInitializationMeasurementStart,
            onInitializationMeasurementStop: onInitializationMeasurementStop,
            onDrawingMeasurementStart: onDrawingMeasurementStart
        )
        present(viewController, animated: true)
    }
    
    @available(iOS 14, *)
    func showLimitedAccessAlert() {
        present(assemblyFactory.limitedAccessAlert(), animated: true)
    }
}
