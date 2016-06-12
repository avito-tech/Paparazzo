import UIKit

final class PhotoRibbonLayout: UICollectionViewFlowLayout {
    
    var itemsTransform = CGAffineTransformIdentity
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewLayout
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        adjustAttributes(attributes)
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElementsInRect(rect)
        attributes?.forEach { $0.transform = itemsTransform }
        return attributes
    }
    
    // MARK: - Private
    
    private func adjustAttributes(attributes: UICollectionViewLayoutAttributes?) {
        attributes?.transform = itemsTransform
    }
}
