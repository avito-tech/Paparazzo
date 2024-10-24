import UIKit

public final class PhotoLibraryV2AssemblyImpl: BasePaparazzoAssembly, PhotoLibraryV2Assembly {
    
    typealias AssemblyFactory = MediaPickerAssemblyFactory & NewCameraAssemblyFactory & LimitedAccessAlertFactory & CameraV3AssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func module(
        data: PhotoLibraryV2Data,
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
    {
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl(photosOrder: .reversed)
        let cameraService = serviceFactory.cameraService(initialActiveCameraType: .back)
        
        let interactor = PhotoLibraryV2InteractorImpl(
            mediaPickerData: data.mediaPickerData,
            selectedItems: data.selectedItems,
            photoLibraryItemsService: photoLibraryItemsService,
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            canRotate: UIDevice.current.userInterfaceIdiom == .pad
        )
        
        let viewController = PhotoLibraryV2ViewController(
            isNewFlowPrototype: isNewFlowPrototype,
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let router = PhotoLibraryV2UIKitRouter(
            assemblyFactory: assemblyFactory,
            cameraService: cameraService,
            viewController: viewController
        )
        
        let presenter = PhotoLibraryV2Presenter(
            interactor: interactor,
            router: router,
            overridenTheme: theme,
            isNewFlowPrototype: isNewFlowPrototype,
            isUsingCameraV3: isUsingCameraV3, 
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled
        )
        
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
