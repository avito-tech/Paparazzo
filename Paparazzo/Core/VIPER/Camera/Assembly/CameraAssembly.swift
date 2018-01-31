import UIKit

protocol CameraAssembly: class {
    func module(initialActiveCameraType: CameraType, overridenTheme: PaparazzoUITheme?) -> (UIView, CameraModuleInput)
}

protocol CameraAssemblyFactory {
    func cameraAssembly() -> CameraAssembly
}
