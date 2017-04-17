import UIKit

struct CameraConfiguration {
    let initialActiveCamera: CameraType
}

final class CameraAssemblyImpl: CameraAssembly {
    
    private let theme: MediaPickerRootModuleUITheme
    private let configuration: CameraConfiguration
    
    init(theme: MediaPickerRootModuleUITheme)
    {
        self.theme = theme
        self.configuration = CameraConfiguration(initialActiveCamera: .front)
    }
    
    // MARK: - CameraAssembly
    
    func module() -> (UIView, CameraModuleInput) {
        
        let cameraService = CameraServiceImpl(initialActiveCamera: configuration.initialActiveCamera)
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
