import Marshroute
import UIKit

protocol MedicalBookCameraMarshrouteAssembly: AnyObject {
    func module(
        isPhotoFetchLimitEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        cameraStatusService: CameraStatusService,
        routerSeed: RouterSeed,
        configure: (MedicalBookCameraModule) -> ()
    ) -> UIViewController
}

protocol MedicalBookCameraMarshrouteAssemblyFactory: AnyObject {
    func medicalBookCameraAssembly() -> MedicalBookCameraMarshrouteAssembly
}

final class MedicalBookCameraMarshrouteAssemblyImpl:
    BasePaparazzoAssembly,
    MedicalBookCameraMarshrouteAssembly
{
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(
        assemblyFactory: AssemblyFactory,
        theme: PaparazzoUITheme,
        serviceFactory: ServiceFactory
    ) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }

    func module(
        isPhotoFetchLimitEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        cameraStatusService: CameraStatusService,
        routerSeed: RouterSeed,
        configure: (MedicalBookCameraModule) -> ()
    ) -> UIViewController {
        let interactor = MedicalBookCameraInteractorImpl(
            mediaPickerData: mediaPickerData,
            selectedImagesStorage: selectedImagesStorage,
            cameraService: cameraService,
            cameraStatusService: cameraStatusService
        )
        
        let router = MedicalBookCameraMarshrouteRouter(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let viewController = MedicalBookCameraViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let presenter = MedicalBookCameraPresenter(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
            interactor: interactor,
            router: router,
            volumeService: serviceFactory.volumeService(),
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
