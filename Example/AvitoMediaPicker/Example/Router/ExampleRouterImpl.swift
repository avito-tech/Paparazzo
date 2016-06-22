import UIKit
import Marshroute
import AvitoMediaPicker

final class ExampleRouterImpl: BaseRouter, ExampleRouter {
    
    private let mediaPickerAssemblyFactory = AvitoMediaPicker.AssemblyFactory()
    
    // MARK: - ExampleRouter
    
    func showMediaPicker(maxItemsCount maxItemsCount: Int?, output: MediaPickerModuleOutput) {
        
        presentModalNavigationControllerWithRootViewControllerDerivedFrom({ routerSeed in
        
            let assembly = mediaPickerAssemblyFactory.mediaPickerAssembly()
            
            return assembly.viewController(
                maxItemsCount: maxItemsCount,
                moduleOutput: output,
                routerSeed: routerSeed
            )
            
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
