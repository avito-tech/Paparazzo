import UIKit

final class PhotoLibraryV2UIKitRouter: BaseUIKitRouter, PhotoLibraryV2Router {
    
    typealias AssemblyFactory = MediaPickerAssemblyFactory & NewCameraAssemblyFactory
    
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
        isMetalEnabled: Bool,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
    {
        let assembly = assemblyFactory.mediaPickerAssembly()
        
        let viewController = assembly.module(
            data: data,
            overridenTheme: overridenTheme,
            isMetalEnabled: isMetalEnabled,
            isNewFlowPrototype: isNewFlowPrototype,
            configure: configure
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func showNewCamera(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        shouldAllowFinishingWithNoPhotos: Bool,
        configure: (NewCameraModule) -> ())
    {
        let assembly = assemblyFactory.newCameraAssembly()
        
        let viewController = assembly.module(
            selectedImagesStorage: selectedImagesStorage,
            mediaPickerData: mediaPickerData,
            cameraService: cameraService,
            shouldAllowFinishingWithNoPhotos: shouldAllowFinishingWithNoPhotos,
            configure: configure
        )
        
        present(viewController, animated: true)
    }
}
