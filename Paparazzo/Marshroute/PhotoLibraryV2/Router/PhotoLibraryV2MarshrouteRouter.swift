import Marshroute
import UIKit

final class PhotoLibraryV2MarshrouteRouter: BaseRouter, PhotoLibraryV2Router {
    typealias AssemblyFactory =
    MediaPickerMarshrouteAssemblyFactory
    & NewCameraMarshrouteAssemblyFactory
    & LimitedAccessAlertFactory
    & CameraV3MarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    private let cameraService: CameraService
    
    init(assemblyFactory: AssemblyFactory, cameraService: CameraService, routerSeed: RouterSeed) {
        self.assemblyFactory = assemblyFactory
        self.cameraService = cameraService
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - PhotoLibraryV2Router
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
    
    func showNewCamera(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        shouldAllowFinishingWithNoPhotos: Bool,
        configure: (NewCameraModule) -> ())
    {
        presentModalViewControllerDerivedFrom { routerSeed in
            
            let assembly = assemblyFactory.newCameraAssembly()
            
            return assembly.module(
                selectedImagesStorage: selectedImagesStorage,
                mediaPickerData: mediaPickerData,
                cameraService: cameraService,
                shouldAllowFinishingWithNoPhotos: shouldAllowFinishingWithNoPhotos,
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
    
    func showCameraV3(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (CameraV3Module) -> ()
    ) {
        presentModalViewControllerDerivedFrom { routerSeed in
            assemblyFactory.cameraV3Assembly().module(
                selectedImagesStorage: selectedImagesStorage,
                mediaPickerData: mediaPickerData,
                cameraService: cameraService,
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
