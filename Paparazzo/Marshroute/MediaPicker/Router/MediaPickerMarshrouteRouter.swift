import ImageSource
import Marshroute

final class MediaPickerMarshrouteRouter: BaseRouter, MediaPickerRouter {
    
    typealias AssemblyFactory = ImageCroppingAssemblyFactory & PhotoLibraryMarshrouteAssemblyFactory

    private let assemblyFactory: AssemblyFactory

    init(assemblyFactory: AssemblyFactory, routerSeed: RouterSeed) {
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }

    // MARK: - PhotoPickerRouter

    func showPhotoLibrary(
        data: PhotoLibraryData,
        configure: (PhotoLibraryModule) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom { routerSeed in
            
            let assembly = assemblyFactory.photoLibraryAssembly()
            
            return assembly.module(
                selectedItems: data.selectedItems,
                maxSelectedItemsCount: data.maxSelectedItemsCount,
                routerSeed: routerSeed,
                configure: configure
            )
        }
    }
    
    func showCroppingModule(
        forImage image: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ())
    {
        pushViewControllerDerivedFrom({ _ in
            
            let assembly = assemblyFactory.imageCroppingAssembly()
            
            return assembly.module(
                image: image,
                canvasSize: canvasSize,
                configure: configure
            )
            
        }, animator: NonAnimatedPushAnimator())
    }
}
