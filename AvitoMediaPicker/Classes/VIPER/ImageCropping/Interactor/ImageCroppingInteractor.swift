import Foundation

protocol ImageCroppingInteractor: class {
    
    func originalImageWithParameters(completion: (ImageSource, ImageCroppingParameters?) -> ())
    func croppedImage(completion: CroppedImageSource -> ())
    func croppedImageAspectRatio(completion: Float -> ())
    
    func setCroppingParameters(_: ImageCroppingParameters)
}