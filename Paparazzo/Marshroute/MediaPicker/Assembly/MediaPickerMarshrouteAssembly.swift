import Marshroute
import UIKit

public protocol MediaPickerMarshrouteAssembly: class {
    func module(
        data: MediaPickerData,
        routerSeed: RouterSeed,
        configure: (MediaPickerModule) -> ())
        -> UIViewController
}

public protocol MediaPickerMarshrouteAssemblyFactory: class {
    func mediaPickerAssembly(theme: PaparazzoUITheme?) -> MediaPickerMarshrouteAssembly
}

public extension MediaPickerMarshrouteAssemblyFactory {
    func mediaPickerAssembly() -> MediaPickerMarshrouteAssembly {
        return mediaPickerAssembly(theme: nil)
    }
}
