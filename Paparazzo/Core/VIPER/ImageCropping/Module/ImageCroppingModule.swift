import ImageSource

public protocol ImageCroppingModule: AnyObject {
    var onDiscard: (() -> ())? { get set }
    var onConfirm: ((ImageSource) -> ())? { get set }
}
