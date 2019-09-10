import Marshroute
import UIKit

final class NewCameraMarshrouteAssemblyImpl:
    BasePaparazzoAssembly,
    NewCameraMarshrouteAssembly
{
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - NewCameraAssembly
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        configure: (NewCameraModule) -> ())
        -> UIViewController
    {
        let interactor = NewCameraInteractorImpl(
            mediaPickerData: mediaPickerData
        )
        
        let viewController = NewCameraViewController(
            selectedImagesStorage: selectedImagesStorage,
            cameraService: cameraService,
            latestLibraryPhotoProvider: serviceFactory.photoLibraryLatestPhotoProvider()
        )
        
        let router = NewCameraMarshrouteRouter(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let presenter = NewCameraPresenter(
            interactor: interactor,
            router: router
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
