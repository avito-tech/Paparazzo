import UIKit
import Marshroute
import AvitoMediaPicker

final class ExampleRouterImpl: BaseRouter, ExampleRouter {
    
    private let mediaPickerAssemblyFactory = AvitoMediaPicker.AssemblyFactory()
    
    // MARK: - ExampleRouter
    
    func showMediaPicker(maxItemsCount maxItemsCount: Int?, configuration: MediaPickerModule -> ()) {
        
        presentModalNavigationControllerWithRootViewControllerDerivedFrom({ routerSeed in
        
            let assembly = mediaPickerAssemblyFactory.mediaPickerAssembly()
            
            let (viewController, module) = assembly.module(
                maxItemsCount: maxItemsCount,
                routerSeed: routerSeed
            )
            
            configuration(module)
            
            return viewController
            
        }, animator: ModalNavigationTransitionsAnimator(), navigationController: NavigationController())
    }
    
    func showPhotoLibrary(
        maxSelectedItemsCount maxSelectedItemsCount: Int?,
        configuration: PhotoLibraryModule -> ()
    ) {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.photoLibraryAssembly()
            
            let (viewController, moduleInput) = assembly.module(
                maxSelectedItemsCount: maxSelectedItemsCount,
                routerSeed: routerSeed
            )
            
            configuration(moduleInput)
            
            return viewController
        }
    }
}
