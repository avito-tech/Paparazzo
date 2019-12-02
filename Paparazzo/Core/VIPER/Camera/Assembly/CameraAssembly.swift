import UIKit

protocol CameraAssembly: class {
    func module(initialActiveCameraType: CameraType, overridenTheme: PaparazzoUITheme?) -> (UIView, CameraModuleInput)
}

protocol CameraAssemblyFactory {
    func cameraAssembly() -> CameraAssembly
}

extension CameraAssembly {
    func module(initialActiveCameraType: CameraType) -> (UIView, CameraModuleInput) {
        return module(initialActiveCameraType: initialActiveCameraType, overridenTheme: nil)
    }
}
