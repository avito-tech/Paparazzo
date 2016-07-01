import Foundation

protocol ImageCroppingViewInput: class {
    
    func setImage(image: ImageSource)
    
    var onDiscardButtonTap: (() -> ())? { get set }
    var onConfirmButtonTap: (() -> ())? { get set }
}