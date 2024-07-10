import Marshroute

final class CameraV3MarshrouteRouter: BaseRouter, CameraV3Router {
    
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, routerSeed: RouterSeed) {
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - NewCameraRouter
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom({ routerSeed in
            
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                data: data,
                overridenTheme: overridenTheme,
                routerSeed: routerSeed,
                isNewFlowPrototype: true,
                configure: configure
            )
        }, animator: ModalNavigationTransitionsAnimator())
    }
}
