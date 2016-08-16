import UIKit

final class PhotoLibraryLayout: UICollectionViewFlowLayout {
    
    private var attributes = [UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero
    
    // MARK: - Constants
    
    private let cellSpacing = CGFloat(5)
    private let numberOfPhotosInRow = 3
    
    // MARK: - PhotoLibraryLayout
    
    func cellSize() -> CGSize {
        if let collectionView = collectionView {
            let contentWidth = collectionView.bounds.size.width
            let itemWidth = (contentWidth - CGFloat(numberOfPhotosInRow - 1) * cellSpacing) / CGFloat(numberOfPhotosInRow)
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return .zero
        }
    }
    
    // MARK: - UICollectionViewLayout
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override func prepareLayout() {
        
        guard let collectionView = collectionView else {
            contentSize = .zero
            attributes = []
            return
        }
        
        attributes.removeAll()
        
        let itemSize = cellSize()
        
        let section = 0
        let numberOfItems = collectionView.numberOfItemsInSection(section)
        
        for item in 0 ..< numberOfItems {
            
            let row = floor(CGFloat(item) / CGFloat(numberOfPhotosInRow))
            let column = CGFloat(item % numberOfPhotosInRow)
            
            let origin = CGPoint(
                x: column * (itemSize.width + cellSpacing),
                y: row * (itemSize.height + cellSpacing)
            )
            
            let indexPath = NSIndexPath(forItem: item, inSection: section)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = CGRect(
                origin: origin,
                size: itemSize
            )
            
            self.attributes.append(attributes)
        }
        
        contentSize = CGSize(
            width: collectionView.bounds.maxX,
            height: attributes.last?.frame.maxY ?? 0
        )
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes.filter { $0.indexPath == indexPath }.first
    }
}
