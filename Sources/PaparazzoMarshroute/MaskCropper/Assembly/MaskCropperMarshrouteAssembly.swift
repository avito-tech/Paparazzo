import Marshroute
import UIKit

public protocol MaskCropperMarshrouteAssembly: AnyObject {
    func module(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        routerSeed: RouterSeed,
        configure: (MaskCropperModule) -> ())
        -> UIViewController
}

public protocol MaskCropperMarshrouteAssemblyFactory: AnyObject {
    func maskCropperAssembly() -> MaskCropperMarshrouteAssembly
}
