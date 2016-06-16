import UIKit

extension UIImageView {
    
    func setImage(image: ImageSource?, size: CGSize? = nil, placeholder: UIImage? = nil) {
        
        let pointSize = (size ?? self.frame.size)
        
        let scale = UIScreen.mainScreen().scale
        let pixelSize = CGSizeMake(pointSize.width * scale, pointSize.height * scale)
        
        self.image = placeholder
        
        if let image = image {
            image.imageFittingSize(pixelSize, contentMode: .AspectFill) { [weak self] (image: UIImage?) in
                self?.image = image
            }
        }
    }
}