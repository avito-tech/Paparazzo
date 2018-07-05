import UIKit

public final class ScannerAssemblyImpl: BasePaparazzoAssembly, ScannerAssembly {
    
    typealias AssemblyFactory = CameraAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - ScannerAssembly
    
    public func module(
        data: ScannerData,
        overridenTheme: PaparazzoUITheme?,
        isMetalEnabled: Bool,
        configure: (ScannerModule) -> ())
        -> UIViewController
    {
        let interactor = ScannerInteractorImpl(
            deviceOrientationService: serviceFactory.deviceOrientationService(),
            cameraCaptureOutputHandlers: data.cameraCaptureOutputHandlers
        )
        
        let viewController = ScannerViewController()

        let router = ScannerUIKitRouter(
            viewController: viewController
        )
        
        let cameraAssembly = assemblyFactory.cameraAssembly()
        let (cameraView, cameraModuleInput) = cameraAssembly.module(
            initialActiveCameraType: data.initialActiveCameraType,
            overridenTheme: overridenTheme,
            isMetalEnabled: isMetalEnabled
        )
        
        let presenter = ScannerPresenter(
            interactor: interactor,
            router: router,
            cameraModuleInput: cameraModuleInput
        )
        
        viewController.addDisposable(presenter)
        viewController.setCameraView(cameraView)
        viewController.setTheme(overridenTheme ?? theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
