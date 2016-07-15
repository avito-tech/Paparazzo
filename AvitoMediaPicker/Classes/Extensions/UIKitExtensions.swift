import UIKit

extension UIView {
    
    func setAnchorPointPreservingFrame(anchorPoint: CGPoint) {
        
        var newPoint = CGPoint(
            x: bounds.size.width * anchorPoint.x,
            y: bounds.size.height * anchorPoint.y
        )
        
        var oldPoint = CGPoint(
            x: bounds.size.width * layer.anchorPoint.x,
            y: bounds.size.height * layer.anchorPoint.y
        )
        
        newPoint = CGPointApplyAffineTransform(newPoint, transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, transform)
        
        layer.position = CGPoint(
            x: layer.position.x - oldPoint.x + newPoint.x,
            y: layer.position.y - oldPoint.y + newPoint.y
        )
        
        layer.anchorPoint = anchorPoint
    }
}

extension UICollectionView {
    
    func performBatchUpdates(updates: () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    func performNonAnimatedBatchUpdates(updates: (() -> Void), completion: (Bool -> ())? = nil) {
        UIView.animateWithDuration(0) { 
            self.performBatchUpdates(updates, completion: completion)
        }
    }
    
    func performBatchUpdates(animated animated: Bool, _ updates: (() -> Void), completion: (Bool -> ())? = nil) {
        let updateCollectionView = animated ? performBatchUpdates : performNonAnimatedBatchUpdates
        updateCollectionView(updates, completion: completion)
    }
    
    func insertItems(animated animated: Bool, _ updates: () -> [NSIndexPath]?) {
        performBatchUpdates(animated: animated, { [weak self] in
            if let indexPaths = updates() {
                self?.insertItemsAtIndexPaths(indexPaths)
            }
        })
    }
    
    func deleteItems(animated animated: Bool, _ updates: () -> [NSIndexPath]?) {
        performBatchUpdates(animated: animated, { [weak self] in
            if let indexPaths = updates() {
                self?.deleteItemsAtIndexPaths(indexPaths)
            }
        })
    }
}

extension UIScrollView {
    
    // Проставляет bounds, сохраняя центральной точкой ту, что была при старом bounds
    func setBoundsSizePreservingContentCenter(size: CGSize) {
        
        let contentCenter = CGPoint(
            x: contentOffset.x + bounds.size.width / 2,
            y: contentOffset.y + bounds.size.height / 2
        )
        
        let newContentOffset = CGPoint(
            x: contentCenter.x - size.width / 2,
            y: contentCenter.y - size.height / 2
        )
        
        bounds = CGRect(origin: newContentOffset, size: size)
    }
}