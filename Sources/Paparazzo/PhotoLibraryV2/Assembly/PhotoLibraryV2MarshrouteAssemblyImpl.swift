import UIKit
import Marshroute

public final class PhotoLibraryV2MarshrouteAssemblyImpl: BasePaparazzoAssembly, PhotoLibraryV2MarshrouteAssembly {
    
    typealias AssemblyFactory =
    MediaPickerMarshrouteAssemblyFactory
    & LimitedAccessAlertFactory
    & CameraV3MarshrouteAssemblyFactory
    & MedicalBookCameraMarshrouteAssemblyFactory
    
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
<<<<<<< HEAD
=======
        cameraType: MediaPickerCameraType?,
>>>>>>> master
        configure: (PhotoLibraryV2Module) -> (),
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> UIViewController {
        
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl(
            photosOrder: .reversed
        )
        
        let cameraService = serviceFactory.cameraService(initialActiveCameraType: .back)
        let cameraStatusService = serviceFactory.cameraStatusService()
        
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
            cameraStatusService: cameraStatusService,
            routerSeed: routerSeed
        )
        
        let presenter = PhotoLibraryV2Presenter(
            interactor: interactor,
            router: router,
            overridenTheme: theme,
            isNewFlowPrototype: isNewFlowPrototype, 
<<<<<<< HEAD
=======
            cameraType: cameraType,
>>>>>>> master
            onCameraV3InitializationMeasurementStart: onCameraV3InitializationMeasurementStart,
            onCameraV3InitializationMeasurementStop: onCameraV3InitializationMeasurementStop,
            onCameraV3DrawingMeasurementStart: onCameraV3DrawingMeasurementStart, 
            onCameraV3DrawingMeasurementStop: onCameraV3DrawingMeasurementStop
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
