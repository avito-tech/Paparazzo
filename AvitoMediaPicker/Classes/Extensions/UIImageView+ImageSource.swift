import UIKit

extension UIImageView {
    
    func setImage(
        image: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        deferredPlaceholder: Bool = false,
        completion: (() -> ())? = nil
    ) {
        let pointSize = (size ?? self.frame.size)
        
        let scale = UIScreen.mainScreen().scale
        let pixelSize = CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
        
        if !deferredPlaceholder {
            self.image = placeholder
        }
        
        if let image = image {
            image.imageFittingSize(pixelSize, contentMode: .AspectFill) { [weak self] (image: UIImage?) in
                self?.image = image
                completion?()
            }
        }
    }
}