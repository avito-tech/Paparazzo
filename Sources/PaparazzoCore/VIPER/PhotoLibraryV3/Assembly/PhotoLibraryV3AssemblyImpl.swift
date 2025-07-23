import UIKit

public final class PhotoLibraryV3AssemblyImpl: BasePaparazzoAssembly, PhotoLibraryV3Assembly {
    
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
        data: PhotoLibraryV3Data,
        cameraType: MediaPickerCameraType,
        configure: (PhotoLibraryV3Module) -> (),
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

        let interactor = PhotoLibraryV3InteractorImpl(
            mediaPickerData: data.mediaPickerData,
            selectedItems: data.selectedItems,
            photoLibraryItemsService: photoLibraryItemsService,
            cameraService: cameraService,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            canRotate: UIDevice.current.userInterfaceIdiom == .pad
        )
        
        let viewController = PhotoLibraryV3ViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let router = PhotoLibraryV3UIKitRouter(
            assemblyFactory: assemblyFactory,
            cameraService: cameraService,
            cameraStatusService: cameraStatusService,
            viewController: viewController
        )
        
        let presenter = PhotoLibraryV3Presenter(
            interactor: interactor,
            router: router,
            overridenTheme: theme,
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
