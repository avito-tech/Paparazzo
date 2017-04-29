import Marshroute
import UIKit

public protocol MaskCropperMarshrouteAssembly: class {
    func module(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        routerSeed: RouterSeed,
        configure: (MaskCropperModule) -> ())
        -> UIViewController
}

public protocol MaskCropperMarshrouteAssemblyFactory: class {
    func circleImageCroppingMarshrouteAssembly() -> MaskCropperAssembly
}
