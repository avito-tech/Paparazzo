import UIKit

public extension UIImageView {
    
    func setImage(
        fromSource newImageSource: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        placeholderDeferred: Bool = false,
        adjustOptions: ((inout options: ImageRequestOptions) -> ())? = nil
    ) {
        let previousImageSource = imageSource
        let pointSize = (size ?? bounds.size)
        let scale = UIScreen.mainScreen().scale
        let pixelSize = CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
        
        if let imageRequestID = imageRequestID {
            previousImageSource?.cancelRequest(imageRequestID)
            self.imageRequestID = nil
        }
        
        if !placeholderDeferred {
            image = placeholder
        }
        
        imageSource = newImageSource
        
        if let newImageSource = newImageSource where pointSize.width > 0 && pointSize.height > 0 {
            
            var options = ImageRequestOptions(size: .FillSize(pixelSize), deliveryMode: .Progressive)
            adjustOptions?(options: &options)
            
            imageRequestID = newImageSource.requestImage(options: options) { [weak self] (image: UIImage?) in
                if let image = image where self?.shouldSetImageForImageSource(newImageSource) == true {
                    self?.image = image
                }
            }
            
        } else {
            image = placeholder
        }
    }
    
    // MARK: - Private
    
    private static var imageSourceKey = "imageSource"
    private static var imageRequestIdKey = "imageRequestId"
    
    private var imageSource: ImageSource? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.imageSourceKey) as? ImageSource
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.imageSourceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var imageRequestID: ImageRequestID? {
        get {
            return (objc_getAssociatedObject(self, &UIImageView.imageRequestIdKey) as? NSNumber)?.intValue
        }
        set {
            let number = newValue.flatMap { NSNumber(int: $0) }
            objc_setAssociatedObject(self, &UIImageView.imageRequestIdKey, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func shouldSetImageForImageSource(imageSource: ImageSource) -> Bool {
        if let currentImageSource = self.imageSource {
            return imageSource == currentImageSource
        } else {
            return true
        }
    }
}