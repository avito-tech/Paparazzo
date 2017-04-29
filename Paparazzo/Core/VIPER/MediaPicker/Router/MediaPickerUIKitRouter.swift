import ImageSource
import UIKit

final class MediaPickerUIKitRouter: BaseUIKitRouter, MediaPickerRouter {
    
    typealias AssemblyFactory = ImageCroppingAssemblyFactory & PhotoLibraryAssemblyFactory

    private let assemblyFactory: AssemblyFactory
    private var cropViewControllers = [WeakWrapper<UIViewController>]()

    init(assemblyFactory: AssemblyFactory, viewController: UIViewController) {
        self.assemblyFactory = assemblyFactory
        super.init(viewController: viewController)
    }

    // MARK: - PhotoPickerRouter

    func showPhotoLibrary(
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ())
    {
        let assembly = assemblyFactory.photoLibraryAssembly()
        
        let viewController = assembly.module(
            data: data,
            configure: configure
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func showCroppingModule(
        forImage image: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ())
    {
        let assembly = assemblyFactory.imageCroppingAssembly()
        
        let viewController = assembly.module(
            image: image,
            canvasSize: canvasSize,
            configure: configure
        )
        
        cropViewControllers.append(WeakWrapper(value: viewController))
        
        push(viewController, animated: false)
    }
    
    override func focusOnCurrentModule() {
        super.focusOnCurrentModule(shouldDismissAnimated: { viewController in
            !cropViewControllers.contains { $0.value == viewController }
        })
    }
}
