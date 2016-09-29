import UIKit

public class ImageSourceCollectionViewCell: UICollectionViewCell {
    
    public var imageSource: ImageSource? {
        didSet {
            // Вызывать тут updateImage() не нужно, так как при реюзинге в любом случае вызовется layoutSubviews(),
            // и фотография будет запрошена дважды, а нам это не нужно. Будем обновлять картинку в layoutSubviews().
            setNeedsLayout()
        }
    }
    
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds.shrinked(imageViewInsets)
        
        updateImage()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.setImage(fromSource: nil)
    }
    
    // MARK: - Subclasses customization
    
    /// This method is called right before requesting image from ImageSource and gives you a chance to tweak request options
    public func adjustImageRequestOptions(_ options: inout ImageRequestOptions) {}
    public func didRequestImage(requestId: ImageRequestId) {}
    public func imageRequestResultReceived(_ result: ImageRequestResult<UIImage>) {}
    
    // MARK: - Private
    
    let imageView = UIImageView()
    
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
