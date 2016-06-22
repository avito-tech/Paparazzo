import UIKit
import Marshroute

public final class MediaPickerAssemblyImpl: MediaPickerAssembly {
    
    typealias AssemblyFactory = protocol<CameraAssemblyFactory, ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory>
    
    private let assemblyFactory: AssemblyFactory
    private let theme: MediaPickerUITheme
    
    init(assemblyFactory: AssemblyFactory, theme: MediaPickerUITheme) {
        self.assemblyFactory = assemblyFactory
        self.theme = theme
    }
    
    // MARK: - MediaPickerAssembly
    
    public func module(
        maxItemsCount maxItemsCount: Int?,
        routerSeed: RouterSeed
    ) -> (UIViewController, MediaPickerModule) {
        
        let interactor = MediaPickerInteractorImpl(
            maxItemsCount: maxItemsCount,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl()
        )

        let router = MediaPickerRouterImpl(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let cameraAssembly = assemblyFactory.cameraAssembly()
        let (cameraView, cameraModuleInput) = cameraAssembly.module()
        
        let presenter = MediaPickerPresenter(
            interactor: interactor,
            router: router,
            cameraModuleInput: cameraModuleInput
        )
        
        let viewController = MediaPickerViewController()
        viewController.addDisposable(presenter)
        viewController.setCameraView(cameraView)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        return (viewController, presenter)
    }
}
