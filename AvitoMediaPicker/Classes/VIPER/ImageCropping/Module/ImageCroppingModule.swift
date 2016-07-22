public protocol ImageCroppingModule: class {
    
    func setImage(_: ImageSource)
    
    var onDiscard: (() -> ())? { get set }
    var onConfirm: (ImageSource -> ())? { get set }
}