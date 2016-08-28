import UIKit

public extension UIImageView {
    
    func setImage(
        fromSource newImageSource: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        placeholderDeferred: Bool = false,
        adjustOptions: ((inout options: ImageRequestOptions) -> ())? = nil,
        resultHandler: (ImageRequestResult<UIImage> -> ())? = nil)
        -> ImageRequestId?
    {
        let previousImageSource = imageSource
        let pointSize = (size ?? bounds.size)
        let scale = UIScreen.mainScreen().scale
        let pixelSize = CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
        
        if let imageRequestId = imageRequestId {
            previousImageSource?.cancelRequest(imageRequestId)
            self.imageRequestId = nil
        }
        
        if !placeholderDeferred {
            image = placeholder
        }
        
        imageSource = newImageSource
        
        if let newImageSource = newImageSource where pixelSize.width > 0 && pixelSize.height > 0 {
            
            let size: ImageSizeOption = (contentMode == .ScaleAspectFit) ? .FitSize(pixelSize) : .FillSize(pixelSize)
            var options = ImageRequestOptions(size: size, deliveryMode: .Progressive)
            adjustOptions?(options: &options)
            
            imageRequestId = newImageSource.requestImage(options: options) { [weak self] (result: ImageRequestResult<UIImage>) in
                let shouldSetImage = self?.shouldSetImageForImageSource(newImageSource, requestId: result.requestId) == true
                
                if let image = result.image where shouldSetImage {
//                    debugPrint("imageSource \(newImageSource), currentImageRequest = \(self?.imageRequestId), imageRequest = \(result.requestId)")
                    self?.image = image
                    resultHandler?(result)
                }
            }
            
        } else {
            image = placeholder
        }
        
        return imageRequestId
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
    
    private var imageRequestId: ImageRequestId? {
        get {
            return (objc_getAssociatedObject(self, &UIImageView.imageRequestIdKey) as? NSNumber)?.intValue
        }
        set {
            let number = newValue.flatMap { NSNumber(int: $0) }
            objc_setAssociatedObject(self, &UIImageView.imageRequestIdKey, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func shouldSetImageForImageSource(imageSource: ImageSource, requestId: ImageRequestId) -> Bool {
        if let currentImageSource = self.imageSource {
            // Если imageRequestId == nil, это значит, что resultHandler вызвался синхронно — еще до того,
            // как метод requestImage завершился и вернул нам ImageRequestId. В этом случае картику поставить нужно.
            return imageSource == currentImageSource && (imageRequestId == nil || requestId == imageRequestId)
        } else {
            return false
        }
    }
}