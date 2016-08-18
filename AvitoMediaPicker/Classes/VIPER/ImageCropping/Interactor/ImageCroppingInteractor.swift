import Foundation
import AvitoDesignKit

protocol ImageCroppingInteractor: class {
    
    func canvasSize(completion: CGSize -> ())
    
    func originalImageWithParameters(completion: (ImageSource, ImageCroppingParameters?) -> ())
    func croppedImage(previewImage _: CGImage, completion: CroppedImageSource -> ())
    func croppedImageAspectRatio(completion: Float -> ())
    
    func setCroppingParameters(_: ImageCroppingParameters)
}