import UIKit

public final class MediaPickerAssemblyImpl: MediaPickerAssembly {
    
    typealias AssemblyFactory = CameraAssemblyFactory & ImageCroppingAssemblyFactory & PhotoLibraryAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    private let theme: PaparazzoUITheme
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme) {
        self.assemblyFactory = assemblyFactory
        self.theme = theme
    }
    
    // MARK: - MediaPickerAssembly
    
    public func module(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropEnabled: Bool,
        cropCanvasSize: CGSize,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
    {
        let interactor = MediaPickerInteractorImpl(
            items: items,
            selectedItem: selectedItem,
            maxItemsCount: maxItemsCount,
            cropCanvasSize: cropCanvasSize,
            deviceOrientationService: DeviceOrientationServiceImpl(),
            latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProviderImpl()
        )
        
        let viewController = MediaPickerViewController()

        let router = MediaPickerUIKitRouter(
            assemblyFactory: assemblyFactory,
            viewController: viewController
        )
        
        let cameraAssembly = assemblyFactory.cameraAssembly()
        let (cameraView, cameraModuleInput) = cameraAssembly.module()
        
        let presenter = MediaPickerPresenter(
            interactor: interactor,
            router: router,
            cameraModuleInput: cameraModuleInput
        )
        
        viewController.addDisposable(presenter)
        viewController.setCameraView(cameraView)
        viewController.setTheme(theme)
        viewController.setShowsCropButton(cropEnabled)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
