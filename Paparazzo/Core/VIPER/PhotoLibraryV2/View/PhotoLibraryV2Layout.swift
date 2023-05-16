import UIKit

final class PhotoLibraryV2Layout: UICollectionViewLayout {
    
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var headerAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var hintAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero
    var hasHeader = true
    var hasHint = true
    var hintOriginYPosition: CGFloat = 0
    
    // MARK: - Constants
    private let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    private let cellSpacing = CGFloat(6)
    private let numberOfPhotosInRow = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
    
    // MARK: - PhotoLibraryV2Layout
    func frameForHeader(at indexPath: IndexPath) -> CGRect? {
        return headerAttributes[indexPath]?.frame
    }
    
    // MARK: - UICollectionViewLayout
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return collectionView.bounds != newBounds
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            contentSize = .zero
            attributes = [:]
            headerAttributes = [:]
            hintAttributes = [:]
            return
        }
        
        attributes.removeAll()
        headerAttributes.removeAll()
        hintAttributes.removeAll()
        
        let itemSize = cellSize()
        
        let section = 0
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        let headerMaxY = setUpHeaderAttributes(section: section)
        let hintMaxY = setUpHintAttributes(headerMaxY: headerMaxY)
        
        var maxY: CGFloat = hintMaxY
        
        for item in 0 ..< numberOfItems {
            
            let row = floor(CGFloat(item) / CGFloat(numberOfPhotosInRow))
            let column = CGFloat(item % numberOfPhotosInRow)
            
            let origin = CGPoint(
                x: insets.left + column * (itemSize.width + cellSpacing),
                y: hintMaxY + insets.top + row * (itemSize.height + cellSpacing)
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
        if hasHint {
            updateHintAttributes()
        }
        
        return headerAttributes.filter { $1.frame.intersects(rect) }.map { $1 } +
        hintAttributes.filter { $1.frame.intersects(rect) }.map { $1 } +
        attributes.filter { $1.frame.intersects(rect) }.map { $1 }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return headerAttributes[indexPath]
        case UICollectionView.elementKindSectionHint:
            return hintAttributes[indexPath]
        default:
            return nil
        }
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
        let headerIndexPath = IndexPath(item: 0, section: 0)
        let headerAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            with: headerIndexPath
        )
        let origin = CGPoint(
            x: insets.left,
            y: insets.top
        )
        
        let width = (collectionView?.width ?? 0) - insets.left - insets.right
        
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
    
    private func setUpHintAttributes(headerMaxY: CGFloat) -> CGFloat {
        let hintIndexPath = IndexPath(item: 0, section: 0)
        let hintAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHint,
            with: hintIndexPath
        )
        let hintOrigin = CGPoint(
            x: insets.left,
            y: hasHint ? headerMaxY + 12 : headerMaxY
        )
        
        let hintWidth = (collectionView?.width ?? 0) - insets.left - insets.right
        
        let hintSize = CGSize(
            width: hintWidth,
            height: hasHint ? HintCollectionReusableView.maxHintViewHeight : 0
        )
        
        hintAttributes.frame = CGRect(
            origin: hintOrigin,
            size: hintSize
        )
        self.hintAttributes[hintIndexPath] = hintAttributes
        hintOriginYPosition = hintAttributes.frame.minY
        
        return hintAttributes.frame.maxY
    }
    
    private func updateHintAttributes() {
        
        guard let collectionView = collectionView else {
            contentSize = .zero
            attributes = [:]
            headerAttributes = [:]
            hintAttributes = [:]
            return
        }
        
        for hintAttribute in hintAttributes.values {
            let offsetY = collectionView.contentOffset.y - hintOriginYPosition < 0 ? hintOriginYPosition : collectionView.contentOffset.y
            hintAttribute.frame.origin.y = offsetY
            var itemHeight = HintCollectionReusableView.maxHintViewHeight
            let minHeaderHeight = HintCollectionReusableView.minHintViewHeight
            if collectionView.contentOffset.y > hintOriginYPosition, collectionView.contentOffset.y < hintOriginYPosition + minHeaderHeight {
                itemHeight = itemHeight - (itemHeight - minHeaderHeight) * (collectionView.contentOffset.y - hintOriginYPosition) / (itemHeight - minHeaderHeight)
            } else if collectionView.contentOffset.y > hintOriginYPosition + minHeaderHeight {
                itemHeight = HintCollectionReusableView.minHintViewHeight
            }
            hintAttribute.frame.size.height = max(minHeaderHeight, itemHeight)
            
            hintAttribute.zIndex = 1
        }
    }
}
