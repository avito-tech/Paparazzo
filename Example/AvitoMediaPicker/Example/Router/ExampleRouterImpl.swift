import UIKit
import Marshroute
import AvitoMediaPicker

final class ExampleRouterImpl: BaseRouter, ExampleRouter {
    
    private let mediaPickerAssemblyFactory = AvitoMediaPicker.AssemblyFactory()
    
    // MARK: - ExampleRouter
    
    func showMediaPicker(maxItemsCount: Int?, output: MediaPickerModuleOutput) {
        
        presentModalViewControllerDerivedFrom { routerSeed in
        
            let assembly = mediaPickerAssemblyFactory.mediaPickerAssembly()
            
            return assembly.viewController(
                maxItemsCount: maxItemsCount,
                moduleOutput: output,
                routerSeed: routerSeed
            )
        }
    }
    
    func showPhotoLibrary(maxItemsCount: Int?, output: PhotoLibraryModuleOutput) {
        
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.photoLibraryAssembly()
            
            return assembly.viewController(
                maxItemsCount: maxItemsCount,
                moduleOutput: output,
                routerSeed: routerSeed
            )
        }
    }
}
