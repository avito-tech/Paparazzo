import UIKit

extension UIImageView {
    
    func setImage(image: LazyImage?, size: CGSize? = nil, placeholder: UIImage? = nil) {
        
        let size = size ?? self.size
        
        self.image = placeholder
        
        if let image = image {
            image.imageFittingSize(size, contentMode: .AspectFill) { [weak self] (image: UIImage?) in
                self?.image = image
            }
        }
    }
}