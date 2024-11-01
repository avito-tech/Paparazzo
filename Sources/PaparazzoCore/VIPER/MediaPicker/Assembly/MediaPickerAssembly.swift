import UIKit

public protocol MediaPickerAssembly: AnyObject {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController
}

public protocol MediaPickerAssemblyFactory: AnyObject {
    func mediaPickerAssembly() -> MediaPickerAssembly
}

public extension MediaPickerAssembly {
    func module(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            isNewFlowPrototype: false,
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            configure: configure
        )
    }
}
