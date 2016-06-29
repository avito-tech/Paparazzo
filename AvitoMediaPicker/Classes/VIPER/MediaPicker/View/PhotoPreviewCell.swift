import UIKit

final class PhotoPreviewCell: PhotoCollectionViewCell {
    
    override class var imageViewContentMode: UIViewContentMode {
        return .ScaleAspectFit
    }
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // TODO: настроить шрифт и текст titleLabel
        titleLabel.textColor = .whiteColor()
        titleLabel.shadowColor = .blackColor()
        titleLabel.shadowOffset = CGSize(width: 0, height: 1)
        
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        titleLabel.centerX = bounds.centerX
        titleLabel.top = 20
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        image = item.image
    }
}
