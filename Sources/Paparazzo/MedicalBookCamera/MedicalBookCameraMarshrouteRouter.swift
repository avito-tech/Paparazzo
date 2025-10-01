import Marshroute

final class MedicalBookCameraMarshrouteRouter: BaseRouter, MedicalBookCameraRouter {
    
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(
        assemblyFactory: AssemblyFactory,
        routerSeed: RouterSeed
    ) {
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - NewCameraRouter
    func showMediaPicker(
        data: MediaPickerData,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isRedesignedMediaPickerEnabled: Bool,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom({ routerSeed in
            
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                data: data,
                overridenTheme: overridenTheme,
                routerSeed: routerSeed,
                isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
                isRedesignedMediaPickerEnabled: isRedesignedMediaPickerEnabled,
                isNewFlowPrototype: true,
                configure: configure
            )
        }, animator: ModalNavigationTransitionsAnimator())
    }
}
