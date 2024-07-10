import ImageSource
import UIKit

protocol ImageCroppingAssembly: AnyObject {
    func module(
        image: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ())
        -> UIViewController
}

protocol ImageCroppingAssemblyFactory: AnyObject {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}
