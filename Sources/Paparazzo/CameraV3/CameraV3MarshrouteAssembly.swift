import Marshroute
import UIKit

protocol CameraV3MarshrouteAssembly: AnyObject {
    func module(
        isPhotoFetchLimitEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        configure: (CameraV3Module) -> (),
        onInitializationMeasurementStart: (() -> ())?,
        onInitializationMeasurementStop: (() -> ())?,
        onDrawingMeasurementStart: (() -> ())?,
        onDrawingMeasurementStop: (() -> ())?
    ) -> UIViewController
}

protocol CameraV3MarshrouteAssemblyFactory: AnyObject {
    func cameraV3Assembly() -> CameraV3MarshrouteAssembly
}

final class CameraV3MarshrouteAssemblyImpl:
    BasePaparazzoAssembly,
    CameraV3MarshrouteAssembly
{
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }

    func module(
        isPhotoFetchLimitEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        configure: (CameraV3Module) -> (),
        onInitializationMeasurementStart: (() -> ())?,
        onInitializationMeasurementStop: (() -> ())?,
        onDrawingMeasurementStart: (() -> ())?,
        onDrawingMeasurementStop: (() -> ())?
    ) -> UIViewController {
        onInitializationMeasurementStart?()
        defer { onInitializationMeasurementStop?() }
        
        let interactor = CameraV3InteractorImpl(
            mediaPickerData: mediaPickerData,
            selectedImagesStorage: selectedImagesStorage,
            cameraService: cameraService
        )
        
        let router = CameraV3MarshrouteRouter(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let viewController = CameraV3ViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let presenter = CameraV3Presenter(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
            interactor: interactor,
            volumeService: serviceFactory.volumeService(),
            router: router,
            onDrawingMeasurementStart: onDrawingMeasurementStart,
            onDrawingMeasurementStop: onDrawingMeasurementStop
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
