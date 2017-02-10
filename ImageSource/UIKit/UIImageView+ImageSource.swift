import UIKit

public final class UIImageSourceView: UIView {
    
    // MARK: - Subviews
    private let imageView = UIImageView()
    
    // MARK: - Data
    private var imageSource: ImageSource?
    private var imageRequestId: ImageRequestId?
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        // TODO: перезапрашивать картинку при изменении bounds?
    }
    
    // MARK: - UIImageSourceView
    
    @discardableResult
    public func setImage(
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
            imageView.image = placeholder
        }
        
        imageSource = newImageSource
        
        if let newImageSource = newImageSource, pixelSize.width > 0 && pixelSize.height > 0 {
            
            let size: ImageSizeOption = (contentMode == .scaleAspectFit) ? .fitSize(pixelSize) : .fillSize(pixelSize)
            var options = ImageRequestOptions(size: size, deliveryMode: .progressive)
            adjustOptions?(&options)
            
            imageRequestId = newImageSource.requestImage(options: options) { [weak self] (result: ImageRequestResult<UIImage>) in
                let shouldSetImage = self?.shouldSetImageForImageSource(newImageSource, requestId: result.requestId) == true
                
                if let image = result.image, shouldSetImage {
//                    debugPrint("imageSource \(newImageSource), currentImageRequest = \(self?.imageRequestId), imageRequest = \(result.requestId)")
                    self?.imageView.image = image
                    resultHandler?(result)
                }
            }
            
        } else {
            imageView.image = placeholder
        }
        
        return imageRequestId
    }
    
    // MARK: - Private
    
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
