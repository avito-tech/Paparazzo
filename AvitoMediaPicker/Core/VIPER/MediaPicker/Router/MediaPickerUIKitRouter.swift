import ImageSource
import UIKit

final class MediaPickerUIKitRouter: BaseUIKitRouter, MediaPickerRouter {
    
    typealias AssemblyFactory = ImageCroppingAssemblyFactory & PhotoLibraryAssemblyFactory

    private let assemblyFactory: AssemblyFactory

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
        
        self.viewController.present(navigationController, animated: true, completion: nil)
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
        
        self.viewController.navigationController?.pushViewController(viewController, animated: false)
    }
}
