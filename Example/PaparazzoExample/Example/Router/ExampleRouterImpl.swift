import UIKit
import Marshroute
import Paparazzo

final class ExampleRouterImpl: BaseRouter, ExampleRouter {
    
    private let mediaPickerAssemblyFactory: MarshrouteAssemblyFactory
    private let photoStorage: PhotoStorage
    
    override init(routerSeed seed: RouterSeed) {
        self.photoStorage = PhotoStorageImpl()
        self.photoStorage.removeAll()
        self.mediaPickerAssemblyFactory = Paparazzo.MarshrouteAssemblyFactory(
            theme: PaparazzoUITheme.appSpecificTheme(),
            photoStorage: photoStorage
        )
        super.init(routerSeed: seed)
    }
    
    // MARK: - ExampleRouter
    
    func showMediaPicker(
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ()
    ) {
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
        configure: (MaskCropperModule) -> ()
    ) {
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
        configure: (PhotoLibraryModule) -> ()
    ) {
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
}
