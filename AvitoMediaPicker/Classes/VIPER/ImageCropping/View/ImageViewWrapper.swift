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
        
        imageView.bounds = CGRect(origin: .zero, size: bounds.size)
        imageView.center = bounds.center
    }
    
    // MARK: - ImageViewWrapper
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    func setImageRotation(angle: CGFloat) {
        let radians = angle * CGFloat(M_PI / 180)
        imageView.transform = CGAffineTransformMakeRotation(radians)
    }
}
