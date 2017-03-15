import UIKit

public extension UIImageView {
    
    /**
     Loads image of appropriate size from image source and assigns it to image view's `image` property.
     
     - Parameter newImageSource: Image source to load image from.
     - Parameter size: Size of image to load (in points). If nil, it will be considered to be image view's size.
     - Parameter placeholder: Image to be used in case of inability to load image from image source.
     - Parameter placeholderDeferred: If true, `placeholder` will be assigned to image view when image loading fails. Otherwise it will be also visible while loading is in process.
     - Parameter adjustOptions: Closure that allows you to affect which `ImageRequestOptions` are actually used when requesting image from image source.
     - Parameter resultHandler: Closure that will be called right after received UIImage is assigned to image view.
     
     - Returns: `ImageRequestId` that allows you to cancel image request via `imageSource.cancelRequest(imageRequestId)`
    */
    @discardableResult
    func setImage(
        fromSource newImageSource: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        placeholderDeferred: Bool = false,
        adjustOptions: ((_ options: inout ImageRequestOptions) -> ())? = nil,
        resultHandler: ((ImageRequestResult<UIImage>) -> ())? = nil)
        -> ImageRequestId?
    {
        let previousImageSource = imageSource
        let pointSize = (size ?? bounds.size)
        let scale = UIScreen.main.scale
        let pixelSize = CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
        
        if let imageRequestId = imageRequestId {
            previousImageSource?.cancelRequest(imageRequestId)
            self.imageRequestId = nil
        }
        
        if !placeholderDeferred {
            image = placeholder
        }
        
        imageSource = newImageSource
        
        if let newImageSource = newImageSource, pixelSize.width > 0 && pixelSize.height > 0 {
            
            let size: ImageSizeOption = (contentMode == .scaleAspectFit) ? .fitSize(pixelSize) : .fillSize(pixelSize)
            var options = ImageRequestOptions(size: size, deliveryMode: .progressive)
            adjustOptions?(&options)
            
            imageRequestId = newImageSource.requestImage(options: options) { [weak self] (result: ImageRequestResult<UIImage>) in
                let shouldSetImage = self?.shouldSetImageForImageSource(newImageSource, requestId: result.requestId) == true
                
                if let image = result.image, shouldSetImage {
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
            let intAsNSNumber = objc_getAssociatedObject(self, &UIImageView.imageRequestIdKey) as? NSNumber
            return intAsNSNumber?.int32Value.toImageRequestId()
        }
        set {
            let number = newValue.flatMap { NSNumber(value: $0.int32Value) }
            objc_setAssociatedObject(self, &UIImageView.imageRequestIdKey, number, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func shouldSetImageForImageSource(_ imageSource: ImageSource, requestId: ImageRequestId) -> Bool {
        if let currentImageSource = self.imageSource {
            // Если imageRequestId == nil, это значит, что resultHandler вызвался синхронно — еще до того,
            // как метод requestImage завершился и вернул нам ImageRequestId. В этом случае картику поставить нужно.
            return imageSource == currentImageSource && (imageRequestId == nil || requestId == imageRequestId)
        } else {
            return false
        }
    }
}
