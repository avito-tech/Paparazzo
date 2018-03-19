import UIKit
import Marshroute

public final class ScannerMarshrouteAssemblyImpl: BasePaparazzoAssembly, ScannerMarshrouteAssembly {
    
    typealias AssemblyFactory = CameraAssemblyFactory & ImageCroppingAssemblyFactory & PhotoLibraryMarshrouteAssemblyFactory & MaskCropperMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func module(
        data: ScannerData,
        routerSeed: RouterSeed,
        configure: (ScannerModule) -> ()
        )
        -> UIViewController {
        
            let interactor = ScannerInteractorImpl(
                deviceOrientationService: serviceFactory.deviceOrientationService(),
                cameraCaptureOutputHandlers: data.cameraCaptureOutputHandlers
            )
            
            let viewController = ScannerViewController()
            
            let router = ScannerMarshrouteRouter(
                routerSeed: routerSeed
            )
            
            let cameraAssembly = assemblyFactory.cameraAssembly()
            let (cameraView, cameraModuleInput) = cameraAssembly.module(
                initialActiveCameraType: data.initialActiveCameraType,
                overridenTheme: theme
            )
            
            let presenter = ScannerPresenter(
                interactor: interactor,
                router: router,
                cameraModuleInput: cameraModuleInput
            )
            
            viewController.addDisposable(presenter)
            viewController.setCameraView(cameraView)
            viewController.setTheme(theme)
            
            presenter.view = viewController
            
            configure(presenter)
            
            return viewController
    }
}
