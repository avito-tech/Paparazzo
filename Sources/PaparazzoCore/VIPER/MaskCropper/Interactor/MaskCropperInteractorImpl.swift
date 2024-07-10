import ImageSource
import CoreGraphics

final class MaskCropperInteractorImpl: MaskCropperInteractor {
    
    private let imageCroppingService: ImageCroppingService
    
    init(imageCroppingService: ImageCroppingService) {
        self.imageCroppingService = imageCroppingService
    }
    
    // MARK: - CroppingInteractor
    
    func canvasSize(completion: @escaping (CGSize) -> ()) {
        imageCroppingService.canvasSize(completion: completion)
    }
    
    func imageWithParameters(completion: @escaping (ImageCroppingData) -> ()) {
        imageCroppingService.imageWithParameters(completion: completion)
    }
    
    func croppedImage(previewImage: CGImage, completion: @escaping (CroppedImageSource) -> ()) {
        imageCroppingService.croppedImage(previewImage: previewImage, completion: completion)
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        imageCroppingService.setCroppingParameters(parameters)
    }
}
