import Marshroute
import AvitoDesignKit

final class MediaPickerRouterImpl: BaseRouter, MediaPickerRouter {
    
    typealias AssemblyFactory = protocol<ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory>

    private let assemblyFactory: AssemblyFactory

    init(assemblyFactory: AssemblyFactory, routerSeed: RouterSeed) {
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }

    // MARK: - PhotoPickerRouter

    func showPhotoLibrary(
        selectedItems selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    ) {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom { routerSeed in
            
            let assembly = assemblyFactory.photoLibraryAssembly()
            
            return assembly.module(
                selectedItems: selectedItems,
                maxSelectedItemsCount: maxSelectedItemsCount,
                routerSeed: routerSeed,
                configuration: configuration
            )
        }
    }
    
    func showCroppingModule(forImage image: ImageSource, configuration: ImageCroppingModule -> ()) {
        
        let animator = NavigationTransitionsAnimator()
        animator.shouldAnimate = false
        
        pushViewControllerDerivedFrom({ routerSeed in
            
            let assembly = assemblyFactory.imageCroppingAssembly()
            
            return assembly.viewController(
                image: image,
                routerSeed: routerSeed,
                configuration: configuration
            )
            
        }, animator: animator)
    }
}