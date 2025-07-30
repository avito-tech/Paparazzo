import UIKit

final class PhotoLibraryV3Layout: UICollectionViewFlowLayout {
    
    // MARK: Properties
    
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var headerAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero
    var hasHeader = true
    
    // MARK: Spec
    
    private enum Spec {
        static let insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        static let cellSpacing = CGFloat(4)
        static let numberOfPhotosInRow = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
    }
    
    // MARK: Public methods
    
    func frameForHeader(at indexPath: IndexPath) -> CGRect? {
        return headerAttributes[indexPath]?.frame
    }
    
    // MARK: Override
    
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
            
            let row = floor(CGFloat(item) / CGFloat(Spec.numberOfPhotosInRow))
            let column = CGFloat(item % Spec.numberOfPhotosInRow)
            
            let origin = CGPoint(
                x: Spec.insets.left + column * (itemSize.width + Spec.cellSpacing),
                y: headerMaxY + Spec.insets.top + row * (itemSize.height + Spec.cellSpacing)
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
}

// MARK: - Private methods

private extension PhotoLibraryV3Layout {
    func cellSize() -> CGSize {
        if let collectionView = collectionView {
            let contentWidth = collectionView.bounds.size.width - Spec.insets.left - Spec.insets.right
            let itemWidth = (contentWidth - CGFloat(Spec.numberOfPhotosInRow - 1) * Spec.cellSpacing) / CGFloat(Spec.numberOfPhotosInRow)
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return .zero
        }
    }
    
    func setUpHeaderAttributes(section: Int) -> CGFloat {
        let headerIndexPath = IndexPath(item: 0, section: section)
        let headerAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            with: headerIndexPath
        )
        let origin = CGPoint(
            x: Spec.insets.left,
            y: Spec.insets.top
        )
        
        let width = (collectionView?.width ?? 0) - Spec.insets.left - Spec.insets.right
        
        let size = CGSize(
            width: width,
            height: hasHeader ? width * 0.36 : 0
        )
        
        headerAttributes.frame = CGRect(
            origin: origin,
            size: size
        )
        self.headerAttributes[headerIndexPath] = headerAttributes
        
        return headerAttributes.frame.maxY
    }
}
