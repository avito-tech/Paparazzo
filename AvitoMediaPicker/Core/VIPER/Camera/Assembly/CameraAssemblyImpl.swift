import UIKit

final class CameraAssemblyImpl: CameraAssembly {
    
    private let theme: MediaPickerRootModuleUITheme
    
    init(theme: MediaPickerRootModuleUITheme) {
        self.theme = theme
    }
    
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
        view.setTheme(theme)
        
        presenter.view = view
        
        return (view, presenter)
    }
}
