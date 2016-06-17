import UIKit

final class CameraAssemblyImpl: CameraAssembly {
    
    // MARK: - CameraAssembly
    
    func module() -> (UIView, CameraModuleInput) {
        
        let cameraService = CameraServiceImpl()
        let deviceOrientationService = DeviceOrientationServiceImpl()
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: deviceOrientationService
        )
        
        let presenter = CameraPresenter(
            interactor: interactor
        )
        
        let view = CameraView()
        view.addDisposable(presenter)
        
        presenter.view = view
        
        return (view, presenter)
    }
}
