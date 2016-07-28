import AvitoDesignKit

final class ImageCroppingInteractorImpl: ImageCroppingInteractor {
    
    private let originalImage: ImageSource
    private var parameters: ImageCroppingParameters?
    
    init(image: ImageSource) {
        if let image = image as? CroppedImageSource {
            originalImage = image.originalImage
            parameters = image.croppingParameters
        } else {
            originalImage = image
        }
    }
    
    // MARK: - CroppingInteractor
    
    func originalImageWithParameters(completion: (ImageSource, ImageCroppingParameters?) -> ()) {
        completion(originalImage, parameters)
    }
    
    func croppedImage(previewImage previewImage: CGImage, completion: CroppedImageSource -> ()) {
        completion(CroppedImageSource(
            originalImage: originalImage,
            parameters: parameters,
            previewImage: previewImage
        ))
    }
    
    func croppedImageAspectRatio(completion: Float -> ()) {
        if let parameters = parameters where parameters.cropSize.height > 0 {
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
    
    func setCroppingParameters(parameters: ImageCroppingParameters) {
        self.parameters = parameters
    }
}
