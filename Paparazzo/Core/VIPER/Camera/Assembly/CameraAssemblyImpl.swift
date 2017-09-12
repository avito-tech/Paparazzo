import UIKit

final class CameraAssemblyImpl: BasePaparazzoAssembly, CameraAssembly {
    
    // MARK: - CameraAssembly
    
    func module(initialActiveCameraType: CameraType) -> (UIView, CameraModuleInput) {
        let deviceOrientationService = DeviceOrientationServiceImpl()
        
        let cameraService = serviceFactory.cameraService(
            initialActiveCameraType: initialActiveCameraType
        )
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: deviceOrientationService
        )
        
        let presenter = CameraPresenter(
            interactor: interactor
        )
        
        let view = CameraView()
        view.addDisposable(presenter)
        view.setTheme(theme)
        
        presenter.view = view
        
        return (view, presenter)
    }
}
