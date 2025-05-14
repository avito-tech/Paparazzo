import UIKit

public final class PhotoLibraryV2AssemblyImpl: BasePaparazzoAssembly, PhotoLibraryV2Assembly {
    
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    & LimitedAccessAlertFactory
    & CameraV3AssemblyFactory
    & MedicalBookCameraAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func module(
        data: PhotoLibraryV2Data,
        isNewFlowPrototype: Bool,
        cameraType: MediaPickerCameraType,
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
            cameraStatusService: cameraStatusService,
            viewController: viewController
        )
        
        let presenter = PhotoLibraryV2Presenter(
            interactor: interactor,
            router: router,
            overridenTheme: theme,
            isNewFlowPrototype: isNewFlowPrototype, 
            cameraType: cameraType,
            onCameraV3InitializationMeasurementStart: onCameraV3InitializationMeasurementStart,
            onCameraV3InitializationMeasurementStop: onCameraV3InitializationMeasurementStop,
            onCameraV3DrawingMeasurementStart: onCameraV3DrawingMeasurementStart, 
            onCameraV3DrawingMeasurementStop: onCameraV3DrawingMeasurementStop
        )
        
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
