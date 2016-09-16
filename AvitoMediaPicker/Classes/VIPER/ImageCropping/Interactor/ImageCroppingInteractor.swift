import Foundation

protocol ImageCroppingInteractor: class {
    
    func canvasSize(completion: @escaping (CGSize) -> ())
    
    func imageWithParameters(completion: @escaping (_ original: ImageSource, _ preview: ImageSource?, _ parameters: ImageCroppingParameters?) -> ())
    func croppedImage(previewImage: CGImage, completion: @escaping (CroppedImageSource) -> ())
    func croppedImageAspectRatio(completion: @escaping (Float) -> ())
    
    func setCroppingParameters(_: ImageCroppingParameters)
}
