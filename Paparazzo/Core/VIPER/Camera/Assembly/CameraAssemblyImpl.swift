import UIKit

final class CameraAssemblyImpl: BasePaparazzoAssembly, CameraAssembly {
    
    // MARK: - CameraAssembly
    
    func module(initialActiveCameraType: CameraType, overridenTheme: PaparazzoUITheme?, metalEnabled: Bool) -> (UIView, CameraModuleInput) {
        let deviceOrientationService = DeviceOrientationServiceImpl()
        
        let cameraService = serviceFactory.cameraService(
            initialActiveCameraType: initialActiveCameraType
        )
        
        cameraService.isMetalEnabled = metalEnabled
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: deviceOrientationService
        )
        
        let presenter = CameraPresenter(
            interactor: interactor
        )
        
        let view = CameraView()
        view.addDisposable(presenter)
        view.setTheme(overridenTheme ?? theme)
        
        presenter.view = view
        
        return (view, presenter)
    }
}
