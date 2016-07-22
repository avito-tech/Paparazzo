final class ImageCroppingInteractorImpl: ImageCroppingInteractor {
    
    private let originalImage: ImageSource
    private var parameters: ImageCroppingParameters?
    
    init(originalImage: ImageSource) {
        self.originalImage = originalImage
    }
    
    // MARK: - CroppingInteractor
    
    func setCroppingParameters(parameters: ImageCroppingParameters) {
        self.parameters = parameters
    }
    
    func performCrop(completion: ImageSource -> ()) {
        if let parameters = parameters {
            completion(CroppedImageSource(originalImage: originalImage, parameters: parameters))
        } else {
            completion(originalImage)
        }
    }
}
