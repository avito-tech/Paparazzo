import Foundation

protocol ImageCroppingViewInput: class {
    
    func setTitle(_: String)
    
    func setImage(_: ImageSource)
    func setImageRotation(_: Float)
    func rotate(by _: CGFloat)
    func setRotationSliderValue(_: Float)
    
    func setAspectRatioMode(_: AspectRatioMode)
    func setAspectRatioButtonTitle(_: String)
    
    func setMinimumRotation(degrees: Float)
    func setMaximumRotation(degrees: Float)
    
    func setCancelRotationButtonTitle(_: String)
    func setCancelRotationButtonVisible(_: Bool)
    
    func setGridVisible(_: Bool)
    func setGridButtonSelected(_: Bool)
    
    var onDiscardButtonTap: (() -> ())? { get set }
    var onConfirmButtonTap: (() -> ())? { get set }
    var onAspectRatioButtonTap: (() -> ())? { get set }
    var onRotateButtonTap: (() -> ())? { get set }
    var onGridButtonTap: (() -> ())? { get set }
    var onRotationAngleChange: (Float -> ())? { get set }
    var onRotationCancelButtonTap: (() -> ())? { get set }
    var onCroppingParametersChange: (ImageCroppingParameters -> ())? { get set }
}