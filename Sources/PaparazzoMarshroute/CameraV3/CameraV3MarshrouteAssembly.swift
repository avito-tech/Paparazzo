import Marshroute
import UIKit

protocol CameraV3MarshrouteAssembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        configure: (CameraV3Module) -> ()
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
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        configure: (CameraV3Module) -> ())
        -> UIViewController
    {
        let interactor = CameraV3InteractorImpl(
            mediaPickerData: mediaPickerData,
            selectedImagesStorage: selectedImagesStorage,
            cameraService: cameraService
        )
        
        let router = CameraV3MarshrouteRouter(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let viewController = CameraV3ViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let presenter = CameraV3Presenter(
            interactor: interactor,
            volumeService: serviceFactory.volumeService(),
            router: router
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
