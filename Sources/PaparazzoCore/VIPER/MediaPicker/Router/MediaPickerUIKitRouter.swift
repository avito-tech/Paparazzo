import ImageSource
import UIKit

final class MediaPickerUIKitRouter: BaseUIKitRouter, MediaPickerRouter {
    
    typealias AssemblyFactory = ImageCroppingAssemblyFactory & PhotoLibraryAssemblyFactory & MaskCropperAssemblyFactory
 
    private let isPhotoFetchLimitEnabled: Bool
    private let assemblyFactory: AssemblyFactory
    private var cropViewControllers = [WeakWrapper<UIViewController>]()

    init(
        isPhotoFetchLimitEnabled: Bool,
        assemblyFactory: AssemblyFactory,
        viewController: UIViewController
    ) {
        self.isPhotoFetchLimitEnabled = isPhotoFetchLimitEnabled
        self.assemblyFactory = assemblyFactory
        super.init(viewController: viewController)
    }

    // MARK: - PhotoPickerRouter

    func showPhotoLibrary(
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ()
    ) {
        let assembly = assemblyFactory.photoLibraryAssembly()
        
        let viewController = assembly.module(
            isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
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
