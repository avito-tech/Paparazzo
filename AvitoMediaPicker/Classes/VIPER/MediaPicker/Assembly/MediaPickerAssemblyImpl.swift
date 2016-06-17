import UIKit
import Marshroute

public final class MediaPickerAssemblyImpl: MediaPickerAssembly {
    
    typealias AssemblyFactory = protocol<ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory>
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory) {
        self.assemblyFactory = assemblyFactory
    }
    
    // MARK: - MediaPickerAssembly
    
    public func viewController(
        maxItemsCount maxItemsCount: Int?,
        moduleOutput moduleOutput: MediaPickerModuleOutput,
        routerSeed: RouterSeed
    ) -> UIViewController {

        let cameraService = CameraServiceImpl()
        
        let interactor = MediaPickerInteractorImpl(
            maxItemsCount: maxItemsCount,
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl()
        )

        let router = MediaPickerRouterImpl(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let presenter = MediaPickerPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = MediaPickerViewController()
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        presenter.moduleOutput = moduleOutput
        
        return viewController
    }
}
