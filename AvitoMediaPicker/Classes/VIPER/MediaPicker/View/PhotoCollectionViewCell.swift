import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var image: ImageSource? {
        didSet {
            updateImage()
        }
    }
    
    var selectedBorderColor: UIColor? = .blueColor() {
        didSet {
            adjustBorderColor()
        }
    }
    
    private let imageView = UIImageView()
    private var renderedSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adjustBorderColor()
        
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        
        if imageView.size != renderedSize {
            updateImage()
        }
    }
    
    override var selected: Bool {
        didSet {
            layer.borderWidth = selected ? 4 : 0
        }
    }
    
    // MARK: - Private
    
    private func updateImage() {
        
        let size = imageView.frame.size
        
        imageView.setImage(image, size: size) { [weak self] in
            self?.renderedSize = size
        }
    }
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.CGColor
    }
}
