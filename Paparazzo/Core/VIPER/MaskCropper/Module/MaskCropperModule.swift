import ImageSource

public protocol MaskCropperModule: class {
    
    func dismissModule()
    
    var onDiscard: (() -> ())? { get set }
    var onConfirm: ((ImageSource) -> ())? { get set }
}
