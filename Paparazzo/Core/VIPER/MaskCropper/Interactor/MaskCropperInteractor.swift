import ImageSource

protocol MaskCropperInteractor: class {
    func canvasSize(completion: @escaping (CGSize) -> ())
    func imageWithParameters(completion: @escaping (ImageCroppingData) -> ())
    func croppedImage(previewImage: CGImage, completion: @escaping (CroppedImageSource) -> ())
}
