import Marshroute

final class NewCameraMarshrouteRouter: BaseRouter, NewCameraRouter {
    
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, routerSeed: RouterSeed) {
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - NewCameraRouter
    func showMediaPicker(
        isPresentingPhotosFromCameraFixEnabled: Bool,
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
                isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
                configure: configure
            )
        }, animator: ModalNavigationTransitionsAnimator())
    }
}
