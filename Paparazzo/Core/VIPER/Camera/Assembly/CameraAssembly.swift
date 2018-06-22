import UIKit

protocol CameraAssembly: class {
    func module(initialActiveCameraType: CameraType, overridenTheme: PaparazzoUITheme?, metalEnabled: Bool) -> (UIView, CameraModuleInput)
}

protocol CameraAssemblyFactory {
    func cameraAssembly() -> CameraAssembly
}

extension CameraAssembly {
    func module(initialActiveCameraType: CameraType, metalEnabled: Bool) -> (UIView, CameraModuleInput) {
        return module(initialActiveCameraType: initialActiveCameraType, overridenTheme: nil, metalEnabled: metalEnabled)
    }
}
