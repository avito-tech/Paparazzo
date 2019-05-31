import UIKit

final class PhotoLibraryV2Layout: UICollectionViewFlowLayout {
    
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var headerAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero
    var hasHeader = true
    
    // MARK: - Constants
    
    private let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    private let cellSpacing = CGFloat(6)
    private let numberOfPhotosInRow = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
    private let headerViewHeight = CGFloat(166)
    
    // MARK: - UICollectionViewLayout
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            contentSize = .zero
            attributes = [:]
            headerAttributes = [:]
            return
        }
        
        attributes.removeAll()
        headerAttributes.removeAll()
        
        let itemSize = cellSize()
        
        let section = 0
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        let headerMaxY = setUpHeaderAttributes(section: section)
        
        var maxY: CGFloat = headerMaxY
        
        for item in 0 ..< numberOfItems {
            
            let row = floor(CGFloat(item) / CGFloat(numberOfPhotosInRow))
            let column = CGFloat(item % numberOfPhotosInRow)
            
            let origin = CGPoint(
                x: insets.left + column * (itemSize.width + cellSpacing),
                y: headerMaxY + insets.top + row * (itemSize.height + cellSpacing)
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
        return
            headerAttributes.filter { $1.frame.intersects(rect) }.map { $1 }
                +
                attributes.filter { $1.frame.intersects(rect) }.map { $1 }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes[indexPath]
    }
    
    // MARK: - Private
    private func cellSize() -> CGSize {
        if let collectionView = collectionView {
            let contentWidth = collectionView.bounds.size.width - insets.left - insets.right
            let itemWidth = (contentWidth - CGFloat(numberOfPhotosInRow - 1) * cellSpacing) / CGFloat(numberOfPhotosInRow)
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return .zero
        }
    }
    
    private func setUpHeaderAttributes(section: Int) -> CGFloat {
        let headerIndexPath = IndexPath(item: 0, section: section)
        let headerAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            with: headerIndexPath
        )
        let origin = CGPoint(
            x: insets.left,
            y: insets.top
        )
        let size = CGSize(
            width: (collectionView?.width ?? 0) - insets.left - insets.right,
            height: hasHeader ? headerViewHeight : 0
        )
        
        headerAttributes.frame = CGRect(
            origin: origin,
            size: size
        )
        self.headerAttributes[headerIndexPath] = headerAttributes
        
        return headerAttributes.frame.maxY
    }
}
