import UIKit
import Marshroute

public final class PhotoLibraryV2MarshrouteAssemblyImpl: BasePaparazzoAssembly, PhotoLibraryV2MarshrouteAssembly {
    
    typealias AssemblyFactory =
    MediaPickerMarshrouteAssemblyFactory
    & NewCameraMarshrouteAssemblyFactory
    & LimitedAccessAlertFactory
    & CameraV3MarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func module(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        routerSeed: RouterSeed,
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        isPaparazzoCellDisablingFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> ()
    ) -> UIViewController {
        
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl(photosOrder: .reversed)
        
        let cameraService = serviceFactory.cameraService(initialActiveCameraType: .back)
        
        let interactor = PhotoLibraryV2InteractorImpl(
            mediaPickerData: mediaPickerData,
            selectedItems: selectedItems,
            photoLibraryItemsService: photoLibraryItemsService,
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            canRotate: UIDevice.current.userInterfaceIdiom == .pad
        )
        
        let router = PhotoLibraryV2MarshrouteRouter(
            assemblyFactory: assemblyFactory,
            cameraService: cameraService,
            routerSeed: routerSeed
        )
        
        let presenter = PhotoLibraryV2Presenter(
            interactor: interactor,
            router: router,
            overridenTheme: theme,
            isNewFlowPrototype: isNewFlowPrototype,
            isUsingCameraV3: isUsingCameraV3,
            isPaparazzoCellDisablingFixEnabled: isPaparazzoCellDisablingFixEnabled
        )
        
        let viewController = PhotoLibraryV2ViewController(
            isNewFlowPrototype: isNewFlowPrototype,
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
