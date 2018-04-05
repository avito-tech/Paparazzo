import UIKit

final class PhotoLibraryV2Layout: UICollectionViewFlowLayout {
    
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero
    
    // MARK: - Constants
    
    private let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    private let cellSpacing = CGFloat(6)
    private let numberOfPhotosInRow = 3
    
    // MARK: - PhotoLibraryLayout
    
    func cameraHeaderSize() -> CGSize {
        if let collectionView = collectionView {
            let contentWidth = collectionView.bounds.size.width - insets.left - insets.right
            return CGSize(width: contentWidth, height: 116)
        } else {
            return .zero
        }
    }
    
    func cellSize() -> CGSize {
        if let collectionView = collectionView {
            let contentWidth = collectionView.bounds.size.width - insets.left - insets.right
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
            self.attributes = [:]
            return
        }
        
        self.attributes.removeAll()
        
        let itemSize = cellSize()
        
        let section = 0
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        var maxY = CGFloat()
        ///
        
        let origin = CGPoint(
            x: insets.left,
            y: insets.top
        )
        
        let indexPath = IndexPath(item: 0, section: section)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(
            origin: origin,
            size: cameraHeaderSize()
        )
        
        maxY = max(maxY, attributes.frame.maxY)
        
        if numberOfItems > 0 {
            self.attributes[indexPath] = attributes
        }
        ///
        for item in 0 ..< numberOfItems  {
            
            let row = floor(CGFloat(item) / CGFloat(numberOfPhotosInRow))
            let column = CGFloat(item % numberOfPhotosInRow)
            
            let origin = CGPoint(
                x: insets.left + (column + CGFloat(numberOfPhotosInRow - 1)) * (itemSize.width + cellSpacing),
                y: insets.top + (row + CGFloat(numberOfPhotosInRow - 1)) * (itemSize.height + cellSpacing)
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
