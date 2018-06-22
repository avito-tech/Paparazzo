import UIKit

public final class PhotoLibraryV2AssemblyImpl: BasePaparazzoAssembly, PhotoLibraryV2Assembly {
    
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    public func module(
        data: PhotoLibraryV2Data,
        isMetalEnabled: Bool,
        configure: (PhotoLibraryV2Module) -> ())
        -> UIViewController
    {
        let photoLibraryItemsService = PhotoLibraryItemsServiceImpl(photosOrder: .reversed)
        
        let interactor = PhotoLibraryV2InteractorImpl(
            mediaPickerData: data.mediaPickerData,
            selectedItems: data.selectedItems,
            maxSelectedItemsCount: data.maxSelectedItemsCount,
            photoLibraryItemsService: photoLibraryItemsService,
            cameraService: serviceFactory.cameraService(initialActiveCameraType: .back),
            deviceOrientationService: DeviceOrientationServiceImpl(),
            canRotate: UIDevice.current.userInterfaceIdiom == .pad
        )
        
        let viewController = PhotoLibraryV2ViewController()
        
        let router = PhotoLibraryV2UIKitRouter(
            assemblyFactory: assemblyFactory,
            viewController: viewController
        )
        
        let presenter = PhotoLibraryV2Presenter(
            interactor: interactor,
            router: router,
            overridenTheme: theme,
            isMetalEnabled: isMetalEnabled
        )
        
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
