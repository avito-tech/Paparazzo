import Foundation
import AvitoDesignKit

protocol ImageCroppingInteractor: class {
    
    func canvasSize(completion: CGSize -> ())
    
    func imageWithParameters(completion: (original: ImageSource, preview: ImageSource?, parameters: ImageCroppingParameters?) -> ())
    func croppedImage(previewImage _: CGImage, completion: CroppedImageSource -> ())
    func croppedImageAspectRatio(completion: Float -> ())
    
    func setCroppingParameters(_: ImageCroppingParameters)
}