import UIKit

final class PhotoLibraryLayout: UICollectionViewFlowLayout {
    
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
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
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            contentSize = .zero
            attributes = [:]
            return
        }
        
        attributes.removeAll()
        
        let itemSize = cellSize()
        
        let section = 0
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        var maxY = CGFloat(0)
        
        for item in 0 ..< numberOfItems {
            
            let row = floor(CGFloat(item) / CGFloat(numberOfPhotosInRow))
            let column = CGFloat(item % numberOfPhotosInRow)
            
            let origin = CGPoint(
                x: column * (itemSize.width + cellSpacing),
                y: row * (itemSize.height + cellSpacing)
            )
            
            let indexPath = IndexPath(item: item, section: section)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(
                origin: origin,
                size: itemSize
            )
            
            maxY = max(maxY, attributes.frame.maxY)
            
            self.attributes[indexPath] = attributes
        }
        
        contentSize = CGSize(
            width: collectionView.bounds.maxX,
            height: maxY
        )
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $1.frame.intersects(rect) }.map { $1 }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
}
