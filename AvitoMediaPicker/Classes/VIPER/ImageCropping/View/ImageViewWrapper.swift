import UIKit

// Эта обертка нужна для того, чтобы UIImageView могла лежать внутри UIScrollView
// и при этом поддерживать вращение (если просто положить ее внутрь UIScrollView, то
// при зуминге трансформация вращения будет сбрасываться).
final class ImageViewWrapper: UIView {
    
    // MARK: - Subviews
    
    private let imageView = UIImageView()
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return imageView.sizeThatFits(size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let initialTransform = imageView.transform
        
        imageView.transform = CGAffineTransformIdentity
        imageView.frame = bounds
        imageView.transform = initialTransform
    }
    
    // MARK: - ImageViewWrapper
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var imageTransform: CGAffineTransform {
        get { return imageView.transform }
        set { imageView.transform = newValue }
    }
    
    func setFocusPoint(point: CGPoint, inView view: UIView) {
        
        let point = imageView.convertPoint(point, fromView: view)
        
        if imageView.size.width > 0 && imageView.size.height > 0 {
            
            let anchorPoint = CGPoint(
                x: point.x / imageView.size.width,
                y: point.y / imageView.size.height
            )
            
            imageView.setAnchorPointPreservingFrame(anchorPoint)
        }
    }
}
