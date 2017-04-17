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
        settings: MediaPickerSettings,
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
        
        let viewController = MediaPickerViewController()

        let router = MediaPickerUIKitRouter(
            assemblyFactory: assemblyFactory,
            viewController: viewController
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
        
        viewController.addDisposable(presenter)
        viewController.setCameraView(cameraView)
        viewController.setTheme(theme)
        viewController.setShowsCropButton(settings.cropEnabled)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
