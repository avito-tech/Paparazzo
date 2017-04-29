import ImageSource
import UIKit

protocol ImageCroppingAssembly: class {
    func module(
        image: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ())
        -> UIViewController
}

protocol ImageCroppingAssemblyFactory: class {
    func imageCroppingAssembly() -> ImageCroppingAssembly
}
