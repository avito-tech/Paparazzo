import UIKit
import Marshroute

final class CameraV3AssemblyImpl:
    BasePaparazzoAssembly,
    CameraV3Assembly
{
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - CameraV3Assembly
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
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
        
        let viewController = CameraV3ViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let router = CameraV3RouterImpl(
            assemblyFactory: assemblyFactory,
            viewController: viewController
        )
        
        
        let presenter = CameraV3Presenter(
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
