import UIKit

public class ImageSourceCollectionViewCell: UICollectionViewCell {
    
    public var imageSource: ImageSource? {
        didSet {
            // Вызывать тут updateImage() не нужно, так как при реюзинге в любом случае вызовется layoutSubviews(),
            // и фотография будет запрошена дважды, а нам это не нужно. Будем обновлять картинку в layoutSubviews().
            setNeedsLayout()
        }
    }
    
    // MARK: - UICollectionViewCell
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        
        updateImage()
    }
    
    public override var selected: Bool {
        didSet {
            layer.borderWidth = selected ? 4 : 0
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancelRequestingImageFromSource()
        imageView.image = nil
    }
    
    // MARK: - Subclasses customization
    
    // Can be used by subclasses to customize image view content mode. Default mode is .ScaleAspectFill
    public final func setImageViewContentMode(contentMode: UIViewContentMode) {
        imageView.contentMode = contentMode
    }
    
    /// This method is called right before requesting image from ImageSource and gives you a chance to tweak request options
    public func adjustImageRequestOptions(inout options: ImageRequestOptions) {}
    
    // MARK: - Private
    
    private let imageView = UIImageView()
    
    private func updateImage() {
        imageView.setImage(fromSource: imageSource, adjustOptions: { [weak self] options in
            self?.adjustImageRequestOptions(&options)
        })
    }
}
