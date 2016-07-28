import Foundation
import AvitoDesignKit

protocol ImageCroppingViewInput: class {
    
    func setTitle(_: String)
    
    func setImage(_: ImageSource)
    func setImage(_: ImageSource, completion: () -> ())
    func setImageTiltAngle(_: Float)
    func turnImageCounterclockwise()
    func setCroppingParameters(_: ImageCroppingParameters)
    func setRotationSliderValue(_: Float)
    
    func setAspectRatio(_: AspectRatio)
    func setAspectRatioButtonTitle(_: String)
    
    func setMinimumRotation(degrees: Float)
    func setMaximumRotation(degrees: Float)
    
    func setCancelRotationButtonTitle(_: String)
    func setCancelRotationButtonVisible(_: Bool)
    
    func setGridVisible(_: Bool)
    func setGridButtonSelected(_: Bool)
    
    var onDiscardButtonTap: (() -> ())? { get set }
    var onConfirmButtonTap: ((previewImage: CGImage) -> ())? { get set }
    var onAspectRatioButtonTap: (() -> ())? { get set }
    var onRotateButtonTap: (() -> ())? { get set }
    var onGridButtonTap: (() -> ())? { get set }
    var onRotationAngleChange: (Float -> ())? { get set }
    var onRotationCancelButtonTap: (() -> ())? { get set }
    var onCroppingParametersChange: (ImageCroppingParameters -> ())? { get set }
}