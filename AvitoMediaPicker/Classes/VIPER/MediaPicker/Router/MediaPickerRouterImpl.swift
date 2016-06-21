import Marshroute

final class MediaPickerRouterImpl: BaseRouter, MediaPickerRouter {
    
    typealias AssemblyFactory = protocol<ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory>

    private let assemblyFactory: AssemblyFactory

    init(assemblyFactory: AssemblyFactory, routerSeed: RouterSeed) {
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }

    // MARK: - PhotoPickerRouter

    func showPhotoLibrary(
        maxItemsCount maxItemsCount: Int?,
        moduleOutput moduleOutput: PhotoLibraryModuleOutput
    ) {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = assemblyFactory.photoLibraryAssembly()
            
            return assembly.viewController(
                maxItemsCount: maxItemsCount,
                moduleOutput: moduleOutput,
                routerSeed: routerSeed
            )
        }
    }
    
    func showCroppingModule(photo photo: MediaPickerItem, moduleOutput: ImageCroppingModuleOutput) {
        pushViewControllerDerivedFrom { routerSeed in
            let assembly = assemblyFactory.imageCroppingAssembly()
            return assembly.viewController(photo: photo, moduleOutput: moduleOutput, routerSeed: routerSeed)
        }
    }
}