import UIKit

protocol CameraAssembly: class {
    func module(initialActiveCameraType: CameraType, overridenTheme: PaparazzoUITheme?, isMetalEnabled: Bool) -> (UIView, CameraModuleInput)
}

protocol CameraAssemblyFactory {
    func cameraAssembly() -> CameraAssembly
}

extension CameraAssembly {
    func module(initialActiveCameraType: CameraType, isMetalEnabled: Bool) -> (UIView, CameraModuleInput) {
        return module(initialActiveCameraType: initialActiveCameraType, overridenTheme: nil, isMetalEnabled: isMetalEnabled)
    }
}
