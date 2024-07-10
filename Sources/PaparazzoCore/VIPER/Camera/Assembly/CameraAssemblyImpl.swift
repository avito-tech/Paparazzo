import UIKit

final class CameraAssemblyImpl: BasePaparazzoAssembly, CameraAssembly {
    
    // MARK: - CameraAssembly
    
    func module(initialActiveCameraType: CameraType, overridenTheme: PaparazzoUITheme?) -> (UIView, CameraModuleInput) {
        let deviceOrientationService = DeviceOrientationServiceImpl()
        
        let cameraService = serviceFactory.cameraService(initialActiveCameraType: initialActiveCameraType)
        
        let locationProvider = serviceFactory.locationProvider()
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: deviceOrientationService,
            imageMetadataWritingService: serviceFactory.imageMetadataWritingService(),
            locationProvider: locationProvider
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
