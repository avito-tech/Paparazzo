import ImageSource

protocol MaskCropperViewInput: class {
    func setCroppingOverlayProvider(_: CroppingOverlayProvider)
    func setConfirmButtonTitle(_: String)
    func setImage(_: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ())
    func setCroppingParameters(_: ImageCroppingParameters)
    func setCanvasSize(_: CGSize)
    func setControlsEnabled(_: Bool)
    
    var onCloseTap: (() -> ())? { get set }
    var onConfirmTap: ((_ previewImage: CGImage?) -> ())? { get set }
    var onDiscardTap: (() -> ())? { get set }

    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? { get set }
}
