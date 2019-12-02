import UIKit
import Marshroute
import Paparazzo

final class ExampleRouterImpl: BaseRouter, ExampleRouter {
    
    private let mediaPickerAssemblyFactory: MarshrouteAssemblyFactory
    
    init(
        mediaPickerAssemblyFactory: MarshrouteAssemblyFactory,
        routerSeed: RouterSeed)
    {
        self.mediaPickerAssemblyFactory = mediaPickerAssemblyFactory
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - ExampleRouter
    
    func showMediaPicker(
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ())
    {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                data: data,
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
    
    func showMaskCropper(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        configure: (MaskCropperModule) -> ())
    {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.maskCropperAssembly()
            
            return assembly.module(
                data: data,
                croppingOverlayProvider: croppingOverlayProvider,
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configure: (PhotoLibraryModule) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.photoLibraryAssembly()
            
            return assembly.module(
                selectedItems: selectedItems,
                maxSelectedItemsCount: maxSelectedItemsCount,
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
    
    func showPhotoLibraryV2(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
        isNewFlowPrototype: Bool,
        configure: (PhotoLibraryV2Module) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.photoLibraryV2Assembly()
            
            return assembly.module(
                mediaPickerData: mediaPickerData,
                selectedItems: selectedItems,
                routerSeed: routerSeed,
                isNewFlowPrototype: isNewFlowPrototype,
                configure: configure
            )
        }
    }
    
    func showScanner(
        data: ScannerData,
        configure: (ScannerModule) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.scannerAssembly()
            
            return assembly.module(
                data: data, 
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
}
