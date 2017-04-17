import Marshroute
import UIKit

public final class MediaPickerMarshrouteAssemblyImpl: MediaPickerMarshrouteAssembly {
    
    typealias AssemblyFactory = CameraAssemblyFactory & ImageCroppingAssemblyFactory & PhotoLibraryMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    private let theme: PaparazzoUITheme
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme) {
        self.assemblyFactory = assemblyFactory
        self.theme = theme
    }
    
    // MARK: - MediaPickerAssembly
    
    public func module(
        settings: MediaPickerSettings,
        routerSeed: RouterSeed,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        let interactor = MediaPickerInteractorImpl(
            items: settings.items,
            selectedItem: settings.selectedItem,
            maxItemsCount: settings.maxItemsCount,
            cropCanvasSize: settings.cropCanvasSize,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl()
        )

        let router = MediaPickerMarshrouteRouter(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let cameraAssembly = assemblyFactory.cameraAssembly(
            initialActiveCamera: settings.initalActiveCamera
        )
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
        viewController.setShowsCropButton(settings.cropEnabled)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
