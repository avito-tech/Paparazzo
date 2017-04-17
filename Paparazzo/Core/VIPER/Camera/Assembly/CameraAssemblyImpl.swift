import UIKit

final class CameraAssemblyImpl: CameraAssembly {
    
    private let theme: MediaPickerRootModuleUITheme
    private let initialActiveCamera: CameraType
    
    init(theme: MediaPickerRootModuleUITheme, initialActiveCamera: CameraType)
    {
        self.theme = theme
        self.initialActiveCamera = initialActiveCamera
    }
    
    // MARK: - CameraAssembly
    
    func module() -> (UIView, CameraModuleInput) {
        
        let cameraService = CameraServiceImpl(initialActiveCamera: initialActiveCamera)
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
