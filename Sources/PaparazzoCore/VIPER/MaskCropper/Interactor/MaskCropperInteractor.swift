import ImageSource
import UIKit

protocol MaskCropperInteractor: AnyObject {
    func canvasSize(completion: @escaping (CGSize) -> ())
    func imageWithParameters(completion: @escaping (ImageCroppingData) -> ())
    func croppedImage(previewImage: CGImage, completion: @escaping (CroppedImageSource) -> ())
    func setCroppingParameters(_ parameters: ImageCroppingParameters)
}
