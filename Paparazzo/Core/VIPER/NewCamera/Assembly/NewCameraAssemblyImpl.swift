import UIKit

final class NewCameraAssemblyImpl:
    BasePaparazzoAssembly,
    NewCameraAssembly
{
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }
    
    // MARK: - NewCameraAssembly
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (NewCameraModule) -> ())
        -> UIViewController
    {
        let interactor = NewCameraInteractorImpl(
            mediaPickerData: mediaPickerData
        )
        
        let viewController = NewCameraViewController(
            selectedImagesStorage: selectedImagesStorage,
            cameraService: serviceFactory.cameraService(initialActiveCameraType: .back, allowSharedSession: true),
            latestLibraryPhotoProvider: serviceFactory.photoLibraryLatestPhotoProvider()
        )
        
        let router = NewCameraRouterImpl(
            assemblyFactory: assemblyFactory,
            viewController: viewController
        )
        
        let presenter = NewCameraPresenter(
            interactor: interactor,
            router: router
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
