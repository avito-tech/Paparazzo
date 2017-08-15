import Marshroute
import UIKit

public final class MediaPickerMarshrouteAssemblyImpl: BasePaparazzoAssembly, MediaPickerMarshrouteAssembly {
    
    typealias AssemblyFactory = CameraAssemblyFactory & ImageCroppingAssemblyFactory & PhotoLibraryMarshrouteAssemblyFactory & MaskCropperMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - MediaPickerAssembly
    
    public func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        let interactor = MediaPickerInteractorImpl(
            items: data.items,
            autocorrectionFilters: data.autocorrectionFilters,
            selectedItem: data.selectedItem,
            maxItemsCount: data.maxItemsCount,
            cropCanvasSize: data.cropCanvasSize,
            deviceOrientationService: serviceFactory.deviceOrientationService(),
            latestLibraryPhotoProvider: serviceFactory.photoLibraryLatestPhotoProvider()
        )

        let router = MediaPickerMarshrouteRouter(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let cameraAssembly = assemblyFactory.cameraAssembly()
        let (cameraView, cameraModuleInput) = cameraAssembly.module(initialActiveCameraType: data.initialActiveCameraType)
        
        let presenter = MediaPickerPresenter(
            interactor: interactor,
            router: router,
            cameraModuleInput: cameraModuleInput
        )
        
        let viewController = MediaPickerViewController()
        viewController.addDisposable(presenter)
        viewController.setCameraView(cameraView)
        viewController.setTheme(theme)
        viewController.setShowsCropButton(data.cropEnabled)
        viewController.setShowsAutocorrectButton(data.autocorrectEnabled)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
