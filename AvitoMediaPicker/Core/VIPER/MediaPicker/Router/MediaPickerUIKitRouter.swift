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
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: (PhotoLibraryModule) -> ())
    {
        let assembly = assemblyFactory.photoLibraryAssembly()
        
        let viewController = assembly.module(
            selectedItems: selectedItems,
            maxSelectedItemsCount: maxSelectedItemsCount,
            configuration: configuration
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func showCroppingModule(
        forImage image: ImageSource,
        canvasSize: CGSize,
        configuration: (ImageCroppingModule) -> ())
    {
        let assembly = assemblyFactory.imageCroppingAssembly()
        
        let viewController = assembly.module(
            image: image,
            canvasSize: canvasSize,
            configuration: configuration
        )
        
        cropViewControllers.append(WeakWrapper(value: viewController))
        
        push(viewController, animated: false)
    }
    
    override func focusOnCurrentModule(shouldDismissAnimated: (UIViewController) -> Bool) {
        super.focusOnCurrentModule(shouldDismissAnimated: { viewController in
            !cropViewControllers.contains { $0.value == viewController }
        })
    }
}
