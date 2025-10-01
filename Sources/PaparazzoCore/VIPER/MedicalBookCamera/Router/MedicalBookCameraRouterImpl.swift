import UIKit
import Marshroute

final class MedicalBookCameraRouterImpl:
    BaseUIKitRouter,
    MedicalBookCameraRouter
{
    typealias AssemblyFactory = MediaPickerAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, viewController: UIViewController) {
        self.assemblyFactory = assemblyFactory
        super.init(viewController: viewController)
    }
    
    // MARK: - NewCameraRouter
    func showMediaPicker(
        data: MediaPickerData,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isRedesignedMediaPickerEnabled: Bool,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
    {
        let assembly = assemblyFactory.mediaPickerAssembly()
        
        let viewController = assembly.module(
            data: data,
            overridenTheme: overridenTheme,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isRedesignedMediaPickerEnabled: isRedesignedMediaPickerEnabled,
            isNewFlowPrototype: true,
            configure: configure
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true, completion: nil)
    }
}
