import Foundation
import ImageSource

protocol ImageCroppingViewInput: class {
    
    func setTitle(_: String)
    
    func setImage(_: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ())
    func setImageTiltAngle(_: Float)
    func turnImageCounterclockwise()
    func setCroppingParameters(_: ImageCroppingParameters)
    func setRotationSliderValue(_: Float)
    func setCanvasSize(_: CGSize)
    func setControlsEnabled(_: Bool)
    
    func setAspectRatio(_: AspectRatio)
    func setAspectRatioButtonTitle(_: String)
    
    func setMinimumRotation(degrees: Float)
    func setMaximumRotation(degrees: Float)
    
    func setCancelRotationButtonTitle(_: String)
    func setCancelRotationButtonVisible(_: Bool)
    
    func setGridVisible(_: Bool)
    func setGridButtonSelected(_: Bool)
    
    var onDiscardButtonTap: (() -> ())? { get set }
    var onConfirmButtonTap: ((_ previewImage: CGImage?) -> ())? { get set }
    var onAspectRatioButtonTap: (() -> ())? { get set }
    var onRotateButtonTap: (() -> ())? { get set }
    var onGridButtonTap: (() -> ())? { get set }
    var onRotationAngleChange: ((Float) -> ())? { get set }
    var onRotationCancelButtonTap: (() -> ())? { get set }
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? { get set }
}
