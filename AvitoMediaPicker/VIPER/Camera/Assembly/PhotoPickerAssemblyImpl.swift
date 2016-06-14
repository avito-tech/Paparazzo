import UIKit
import Marshroute

public final class PhotoPickerAssemblyImpl: PhotoPickerAssembly {
    
    typealias AssemblyFactory = protocol<ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory>
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory) {
        self.assemblyFactory = assemblyFactory
    }
    
    // MARK: - MediaPickerAssembly
    
    public func viewController(
        moduleOutput moduleOutput: PhotoPickerModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController {

        let imageResizingService = ImageResizingServiceImpl()
        let cameraService = CameraServiceImpl(imageResizingService: imageResizingService)
        
        let interactor = CameraInteractorImpl(
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl(),
            imageResizingService: imageResizingService
        )

        let router = CameraRouterImpl(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let presenter = CameraPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = CameraViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        presenter.moduleOutput = moduleOutput
        
        return viewController
    }
}
