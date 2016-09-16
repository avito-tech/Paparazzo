import UIKit

final class ThumbnailsViewLayout: UICollectionViewFlowLayout {
    
    var itemsTransform = CGAffineTransform.identity
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewLayout
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        adjustAttributes(attributes)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        attributes?.forEach { attributes in
            
            let delegate = collectionView?.delegate as? MediaRibbonLayoutDelegate
            let shouldApplyTransform = delegate?.shouldApplyTransformToItemAtIndexPath(attributes.indexPath) ?? true
            
            if shouldApplyTransform {
                attributes.transform = itemsTransform
            }
        }
        
        return attributes
    }
    
    // MARK: - Private
    
    private func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes?) {
        attributes?.transform = itemsTransform
    }
}

protocol MediaRibbonLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func shouldApplyTransformToItemAtIndexPath(_ indexPath: IndexPath) -> Bool
}
