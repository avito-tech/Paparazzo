import ImageSource

protocol MaskCropperViewInput: class {
    func setImage(_: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ())
    func setCroppingParameters(_: ImageCroppingParameters)
    func setCanvasSize(_: CGSize)
    func setControlsEnabled(_: Bool)
    
    var onConfirmTap: ((_ previewImage: CGImage?) -> ())? { get set }
    var onDiscardTap: (() -> ())? { get set }

    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? { get set }
}
