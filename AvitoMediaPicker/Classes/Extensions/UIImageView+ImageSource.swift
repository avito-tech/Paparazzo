import UIKit

public extension UIImageView {
    
    func setImage(
        fromSource imageSource: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        placeholderDeferred: Bool = false,
        configureRequest: ((inout options: ImageRequestOptions) -> ())? = nil,
        completion: (() -> ())? = nil
    ) {
        let pointSize = (size ?? self.bounds.size)
        
        guard pointSize.width > 0 && pointSize.height > 0 else {
            self.image = nil
            completion?()
            return
        }
        
        self.imageSource = imageSource
        
        let scale = UIScreen.mainScreen().scale
        let pixelSize = CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
        
        if !placeholderDeferred {
            self.image = placeholder
        }
        
        if let imageSource = imageSource {
            
            if let imageRequestID = imageRequestID {
                imageSource.cancelRequest(imageRequestID)
            }
            
            var options = ImageRequestOptions(size: .FillSize(pixelSize), deliveryMode: .Progressive)
            configureRequest?(options: &options)
            
            imageRequestID = imageSource.requestImage(options: options) { [weak self] (image: UIImage?) in
                if let image = image where self?.shouldSetImageForImageSource(imageSource) == true {
                    self?.image = image
                }
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    @available(*, deprecated=0.0.9, message="Use setImage(fromSource:size:placeholder:placeholderDeferred:completion) instead")
    func setImage(
        imageSource: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        deferredPlaceholder: Bool = false,
        completion: (() -> ())? = nil
    ) {
        setImage(
            fromSource: imageSource,
            size: size,
            placeholder: placeholder,
            placeholderDeferred: deferredPlaceholder,
            completion: completion
        )
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