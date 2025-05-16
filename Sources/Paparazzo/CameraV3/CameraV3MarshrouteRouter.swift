import Marshroute

final class CameraV3MarshrouteRouter: BaseRouter, CameraV3Router {
    
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let isPhotoFetchLimitEnabled: Bool
    private let assemblyFactory: AssemblyFactory
    
    init(
        isPhotoFetchLimitEnabled: Bool,
        assemblyFactory: AssemblyFactory,
        routerSeed: RouterSeed
    ) {
        self.isPhotoFetchLimitEnabled = isPhotoFetchLimitEnabled
        self.assemblyFactory = assemblyFactory
        super.init(routerSeed: routerSeed)
    }
    
    // MARK: - NewCameraRouter
    func showMediaPicker(
        isPhotoFetchLimitEnabled: Bool,
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
    {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom({ routerSeed in
            
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
                data: data,
                overridenTheme: overridenTheme,
                routerSeed: routerSeed,
                isNewFlowPrototype: true, 
                configure: configure
            )
        }, animator: ModalNavigationTransitionsAnimator())
    }
}
