import ImageSource

public protocol MaskCropperModule: AnyObject {
    
    func dismissModule()
    
    var onDiscard: (() -> ())? { get set }
    var onConfirm: ((ImageSource) -> ())? { get set }
}
