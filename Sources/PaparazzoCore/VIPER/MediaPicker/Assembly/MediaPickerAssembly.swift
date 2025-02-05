import UIKit

public protocol MediaPickerAssembly: AnyObject {
    func module(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController
}

public protocol MediaPickerAssemblyFactory: AnyObject {
    func mediaPickerAssembly() -> MediaPickerAssembly
}

public extension MediaPickerAssembly {
    func module(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        data: MediaPickerData,
        configure: (MediaPickerModule) -> ()
    ) -> UIViewController {
        return module(
            data: data,
            overridenTheme: nil,
            isNewFlowPrototype: false,
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            isPhotoFetchingByPageEnabled: isPhotoFetchingByPageEnabled,
            configure: configure
        )
    }
}
