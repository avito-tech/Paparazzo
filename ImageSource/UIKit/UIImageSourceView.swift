import UIKit

public final class UIImageSourceView: UIView {
    
    // MARK: - Subviews
    private let imageView = UIImageView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override var contentMode: UIViewContentMode {
        get { return imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        updateImage()
    }
    
    // MARK: - UIImageSourceView
    
    public var imageSource: ImageSource? {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Private
    
    private func updateImage() {
        
        let sizeInPixels = CGSize(
            width: imageView.frame.width * contentScaleFactor,
            height: imageView.frame.height * contentScaleFactor
        )
        
        imageView.setImage(
            fromSource: imageSource,
            size: sizeInPixels
        )
    }
}
