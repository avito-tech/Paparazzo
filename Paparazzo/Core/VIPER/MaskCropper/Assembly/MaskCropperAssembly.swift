import ImageSource
import UIKit

public protocol MaskCropperAssembly: class {
    func module(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        configure: (MaskCropperModule) -> ())
        -> UIViewController
}

public protocol MaskCropperAssemblyFactory: class {
    func maskCropperAssembly() -> MaskCropperAssembly
}
