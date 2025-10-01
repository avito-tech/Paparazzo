import UIKit

final class MediaItemThumbnailCell: PhotoCollectionViewCell, Customizable {
    
    // MARK: - Init
    
    var isRedesignedMediaPickerEnabled: Bool = false {
        didSet {
            setUpCornerRadius()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = Spec.legacyCornerRadius
        layer.masksToBounds = true
        
        imageView.layer.cornerRadius = Spec.legacyCornerRadius
        imageView.layer.masksToBounds = true
        
        imageViewInsets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(_ item: MediaPickerItem) {
        imageSource = item.image
        setUpCornerRadius()
    }
    
    private func setUpCornerRadius() {
        if isRedesignedMediaPickerEnabled {
            layer.cornerRadius = Spec.newCornerRadius
            imageView.layer.cornerRadius = Spec.newCornerRadius
            selectedBorderThickness = Spec.newSelectedBorderThickness
        } else {
            layer.cornerRadius = Spec.legacyCornerRadius
            imageView.layer.cornerRadius = Spec.legacyCornerRadius
            selectedBorderThickness = Spec.legacySelectedBorderThickness
        }
    }
    
    private enum Spec {
        static let newCornerRadius = 12.0
        static let legacyCornerRadius = 6.0
        
        static let newSelectedBorderThickness = 2.0
        static let legacySelectedBorderThickness = 4.0
    }
}
