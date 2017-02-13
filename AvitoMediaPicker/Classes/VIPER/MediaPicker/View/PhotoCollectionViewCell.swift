import ImageSource
import UIKit

class PhotoCollectionViewCell: UIImageSourceCollectionViewCell {
    
    var selectedBorderColor: UIColor? = .blue {
        didSet {
            adjustBorderColor()
        }
    }
    
    // MARK: - UICollectionViewCell
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adjustBorderColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 4 : 0
        }
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.cgColor
    }
}
