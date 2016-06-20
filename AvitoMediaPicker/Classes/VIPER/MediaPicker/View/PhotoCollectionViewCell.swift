import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var image: ImageSource? {
        didSet {
            updateImage()
        }
    }
    
    var selectedBorderColor: UIColor = .blueColor() {
        didSet {
            adjustBorderColor()
        }
    }
    
    private let imageView = UIImageView()
    
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

        // TODO: придумать что-нибудь поумнее
        let previousImageSize = imageView.frame.size
        
        imageView.frame = contentView.bounds
        
        if imageView.size != previousImageSize {
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
        imageView.setImage(image)
    }
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor.CGColor
    }
}
