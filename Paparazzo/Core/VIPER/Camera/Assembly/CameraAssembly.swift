import UIKit

protocol CameraAssembly: class {
    func module(initialActiveCameraType: CameraType) -> (UIView, CameraModuleInput)
}

protocol CameraAssemblyFactory {
    func cameraAssembly() -> CameraAssembly
}
