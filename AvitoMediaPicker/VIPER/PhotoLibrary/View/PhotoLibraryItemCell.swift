import UIKit

final class PhotoLibraryItemCell: PhotoCollectionViewCell, Customizable {
    
    static let reuseIdentifier = "PhotoLibraryItemCell"

    // MARK: - UICollectionViewCell
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: PhotoLibraryItemCellData) {
        image = item.image
        selected = item.selected
    }
}
