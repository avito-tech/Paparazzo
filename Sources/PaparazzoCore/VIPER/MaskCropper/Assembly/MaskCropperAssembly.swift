import ImageSource
import UIKit

public protocol MaskCropperAssembly: AnyObject {
    func module(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        configure: (MaskCropperModule) -> ())
        -> UIViewController
}

public protocol MaskCropperAssemblyFactory: AnyObject {
    func maskCropperAssembly() -> MaskCropperAssembly
}
