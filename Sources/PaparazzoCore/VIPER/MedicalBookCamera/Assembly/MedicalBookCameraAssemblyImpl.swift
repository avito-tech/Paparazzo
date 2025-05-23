import UIKit
import Marshroute

final class MedicalBookCameraAssemblyImpl:
    BasePaparazzoAssembly,
    MedicalBookCameraAssembly
{
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(
        assemblyFactory: AssemblyFactory,
        theme: PaparazzoUITheme,
        serviceFactory: ServiceFactory
    ) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - MedicalBookCameraAssembly
    func module(
        isPhotoFetchLimitEnabled: Bool,
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        cameraStatusService: CameraStatusService,
        configure: (MedicalBookCameraModule) -> ()
    ) -> UIViewController {
        let interactor = MedicalBookCameraInteractorImpl(
            mediaPickerData: mediaPickerData,
            selectedImagesStorage: selectedImagesStorage,
            cameraService: cameraService,
            cameraStatusService: cameraStatusService
        )
        
        let viewController = MedicalBookCameraViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let router = MedicalBookCameraRouterImpl(
            assemblyFactory: assemblyFactory,
            viewController: viewController
        )
        
        
        let presenter = MedicalBookCameraPresenter(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
            interactor: interactor,
            router: router,
            volumeService: serviceFactory.volumeService()
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
   
}
