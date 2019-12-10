import Marshroute
import UIKit

public final class MediaPickerMarshrouteAssemblyImpl: BasePaparazzoAssembly, MediaPickerMarshrouteAssembly {
    
    typealias AssemblyFactory = CameraAssemblyFactory & ImageCroppingAssemblyFactory
        & PhotoLibraryMarshrouteAssemblyFactory & MaskCropperMarshrouteAssemblyFactory
        & NewCameraMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - MediaPickerAssembly
    
    public func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        viewfinderOverlay: UIView?,
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        let interactor = MediaPickerInteractorImpl(
            items: data.items,
            autocorrectionFilters: data.autocorrectionFilters,
            selectedItem: data.selectedItem,
            maxItemsCount: data.maxItemsCount,
            cropCanvasSize: data.cropCanvasSize,
            cameraEnabled: data.cameraEnabled,
            photoLibraryEnabled: data.photoLibraryEnabled,
            deviceOrientationService: serviceFactory.deviceOrientationService(),
            latestLibraryPhotoProvider: serviceFactory.photoLibraryLatestPhotoProvider()
        )

        let router = MediaPickerMarshrouteRouter(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let cameraAssembly = assemblyFactory.cameraAssembly()
        let (cameraView, cameraModuleInput) = cameraAssembly.module(
            initialActiveCameraType: data.initialActiveCameraType,
            overridenTheme: overridenTheme
        )
        
        let presenter = MediaPickerPresenter(
            isNewFlowPrototype: isNewFlowPrototype,
            interactor: interactor,
            router: router,
            cameraModuleInput: cameraModuleInput
        )
        
        let viewController = MediaPickerViewController()
        viewController.addDisposable(presenter)
        viewController.setCameraView(cameraView)
        viewController.setTheme(overridenTheme ?? theme)
        viewController.setShowsCropButton(data.cropEnabled)
        viewController.setShowsAutocorrectButton(data.autocorrectEnabled)
        viewController.setHapticFeedbackEnabled(data.hapticFeedbackEnabled)
        viewController.setViewfinderOverlay(viewfinderOverlay)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
