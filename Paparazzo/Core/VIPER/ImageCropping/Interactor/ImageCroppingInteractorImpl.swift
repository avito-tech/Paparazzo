import ImageSource

final class ImageCroppingInteractorImpl: ImageCroppingInteractor {
    
    private let originalImage: ImageSource
    private let previewImage: ImageSource?
    private var parameters: ImageCroppingParameters?
    private let canvasSize: CGSize
    
    init(image: ImageSource, canvasSize: CGSize) {
        
        if let image = image as? CroppedImageSource {
            originalImage = image.originalImage
            parameters = image.croppingParameters
        } else {
            originalImage = image
        }
        
        previewImage = image
        
        self.canvasSize = canvasSize
    }
    
    // MARK: - CroppingInteractor
    
    func canvasSize(completion: @escaping (CGSize) -> ()) {
        completion(canvasSize)
    }
    
    func imageWithParameters(completion: @escaping (_ original: ImageSource, _ preview: ImageSource?, _ parameters: ImageCroppingParameters?) -> ()) {
        completion(originalImage, previewImage, parameters)
    }
    
    func croppedImage(previewImage: CGImage, completion: @escaping (CroppedImageSource) -> ()) {
        completion(CroppedImageSource(
            originalImage: originalImage,
            sourceSize: canvasSize,
            parameters: parameters,
            previewImage: previewImage
        ))
    }
    
    func croppedImageAspectRatio(completion: @escaping (Float) -> ()) {
        if let parameters = parameters, parameters.cropSize.height > 0 {
            completion(Float(parameters.cropSize.width / parameters.cropSize.height))
        } else {
            originalImage.imageSize { size in
                if let size = size {
                    completion(Float(size.width / size.height))
                } else {
                    completion(AspectRatio.defaultRatio.widthToHeightRatio())
                }
            }
        }
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        self.parameters = parameters
    }
}
