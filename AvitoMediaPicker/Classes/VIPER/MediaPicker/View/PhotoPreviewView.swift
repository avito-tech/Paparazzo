import UIKit

final class PhotoPreviewView: UIView {
    
    private let imageView = UIImageView()
    
    private var imageTransform = CGAffineTransformIdentity
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageTranform(transform: CGAffineTransform) {
        imageTransform = transform
        adjustImagePosition()
    }
    
    func setImage(
        image: ImageSource?,
        size: CGSize? = nil,
        placeholder: UIImage? = nil,
        deferredPlaceholder: Bool = false,
        completion: (() -> ())? = nil
    ) {
        imageView.setImage(
            image,
            size: size ?? bounds.size,
            placeholder: placeholder,
            deferredPlaceholder: deferredPlaceholder
        ) { [weak self] in
            self?.adjustImagePosition()
            completion?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.center = bounds.center
    }
    
    private func adjustImagePosition() {
        
        guard let image = imageView.image else { return }
        
        let viewSize = CGRectApplyAffineTransform(bounds, imageTransform).size
        
        let scale = min(
            min(viewSize.width / image.size.width, 1),
            min(viewSize.height / image.size.height, 1)
        )
        
        imageView.bounds = CGRect(
            x: 0,
            y: 0,
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        imageView.transform = imageTransform
    }
}