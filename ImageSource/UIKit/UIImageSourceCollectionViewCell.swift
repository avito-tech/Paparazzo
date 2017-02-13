import UIKit

open class UIImageSourceCollectionViewCell: UICollectionViewCell {
    
    public var imageSource: ImageSource? {
        didSet {
            // Вызывать тут updateImage() не нужно, так как при реюзинге в любом случае вызовется layoutSubviews(),
            // и фотография будет запрошена дважды, а нам это не нужно. Будем обновлять картинку в layoutSubviews().
            setNeedsLayout()
        }
    }
    
    public let imageView = UIImageView()
    public var imageViewInsets = UIEdgeInsets.zero
    
    // MARK: - UICollectionViewCell
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = UIEdgeInsetsInsetRect(contentView.bounds, imageViewInsets)
        
        updateImage()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        imageView.setImage(fromSource: nil)
    }
    
    // MARK: - Subclasses customization
    
    /// This method is called right before requesting image from ImageSource and gives you a chance to tweak request options
    open func adjustImageRequestOptions(_ options: inout ImageRequestOptions) {}
    open func didRequestImage(requestId: ImageRequestId) {}
    open func imageRequestResultReceived(_ result: ImageRequestResult<UIImage>) {}
    
    // MARK: - Private
    
    private func updateImage() {
        
        // Этот флажок нужен для того, чтобы гарантировать, что imageRequestResultReceived будет вызван после didRequestImage
        // (если ImageSource вызовет resultHandler синхронно, то будет наоборот)
        var didCallRequestImage = false
        var delayedResult: ImageRequestResult<UIImage>?
        
        let requestId = imageView.setImage(
            fromSource: imageSource,
            adjustOptions: { [weak self] options in
                self?.adjustImageRequestOptions(&options)
            },
            resultHandler: { [weak self] result in
                if didCallRequestImage {
                    self?.imageRequestResultReceived(result)
                } else {
                    delayedResult = result
                }
            }
        )
        
        if let requestId = requestId {
            
            didRequestImage(requestId: requestId)
            didCallRequestImage = true
            
            if let delayedResult = delayedResult {
                imageRequestResultReceived(delayedResult)
            }
        }
    }
}
