import UIKit

final class PhotoLibraryV2Layout: UICollectionViewFlowLayout {

    private enum ItemDisplayType {
        case regular
        case expanded
    }
    
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero
    
    // MARK: - Constants
    
    private let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    private let cellSpacing = CGFloat(6)
    private let numberOfPhotosInRow = 3
    
    // MARK: - PhotoLibraryLayout
    
    func expandedSize() -> CGSize {
        if let collectionView = collectionView {
            let contentWidth = collectionView.bounds.size.width - insets.left - insets.right
            return CGSize(width: contentWidth, height: 116)
        } else {
            return .zero
        }
    }
    
    func regularSize() -> CGSize {
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
        
        let regularSize = self.regularSize()
        let expandedSize = self.expandedSize()
        
        let section = 0
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        var cursorX = insets.left
        var cursorY = insets.top
        
        for item in 0 ..< numberOfItems  {
            let indexPath = IndexPath(item: item, section: section)
            let itemSize: CGSize
            switch styleForItemAtIndexPath(indexPath) {
            case .regular:
                itemSize = regularSize
            case .expanded:
                itemSize = expandedSize
            }
            let necessaryItemWidth = itemSize.width
            let needsNewLine = (cursorX + necessaryItemWidth > collectionView.bounds.size.width)
            let x = needsNewLine ? insets.left : cursorX
            let y = needsNewLine ? cursorY + itemSize.height + cellSpacing : cursorY
            let origin = CGPoint(
                x: x,
                y: y
            )
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(
                origin: origin,
                size: itemSize
            )
            
            cursorY = max(cursorY, attributes.frame.minY)
            cursorX = attributes.frame.maxX + cellSpacing
            
            self.attributes[indexPath] = attributes
        }
        
        contentSize = CGSize(
            width: collectionView.bounds.maxX,
            height: cursorY
        )
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $1.frame.intersects(rect) }.map { $1 }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
    
    private func styleForItemAtIndexPath(_ indexPath: IndexPath) -> ItemDisplayType {
        let item = collectionView?.cellForItem(at: indexPath)
        if ((item as? PhotoLibraryItemCell) != nil) {
            return .regular
        } else if ((item as? PhotoLibraryCameraCell) != nil) {
            return .expanded
        }
        
        return .regular
    }
}
