import ImageSource

public protocol ImageCroppingModule: AnyObject {
    var onDiscard: (() -> ())? { get set }
    var onConfirm: ((ImageSource) -> ())? { get set }
    var onRotationAngleChange: (() -> ())? { get set }
    var onRotateButtonTap: (() -> ())? { get set }
    var onGridButtonTap: ((Bool) -> ())? { get set }
    var onAspectRatioButtonTap: ((String) -> ())? { get set }
}
