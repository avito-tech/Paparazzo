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
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        layer.position = CGPoint(
            x: layer.position.x - oldPoint.x + newPoint.x,
            y: layer.position.y - oldPoint.y + newPoint.y
        )
        
        layer.anchorPoint = anchorPoint
    }
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func removeFromSuperviewAfterFadingOut(withDuration duration: TimeInterval) {
        
        UIView.animate(
            withDuration: duration,
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }
}

extension UICollectionView {
    
    func performBatchUpdates(updates: @escaping () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    func performNonAnimatedBatchUpdates(updates: @escaping () -> Void, completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: 0) { 
            self.performBatchUpdates(updates, completion: completion)
        }
    }
    
    func performBatchUpdates(animated: Bool, _ updates: @escaping () -> Void, completion: ((Bool) -> ())? = nil) {
        let updateCollectionView = animated ? performBatchUpdates : performNonAnimatedBatchUpdates
        updateCollectionView(updates, completion)
    }
    
    func insertItems(animated: Bool, _ updates: @escaping () -> [IndexPath]?) {
        performBatchUpdates(animated: animated, { [weak self] in
            if let indexPaths = updates() {
                self?.insertItems(at: indexPaths)
            }
        })
    }
    
    func deleteItems(animated: Bool, _ updates: @escaping () -> [IndexPath]?) {
        performBatchUpdates(animated: animated, { [weak self] in
            if let indexPaths = updates() {
                self?.deleteItems(at: indexPaths)
            }
        })
    }
}

extension UIImage {
    
    func scaled(scale: CGFloat) -> UIImage? {
        return cgImage?.scaled(scale).flatMap { UIImage(cgImage: $0) }
    }
    
    func resized(toFit size: CGSize) -> UIImage? {
        return cgImage?.resized(toFit: size).flatMap { UIImage(cgImage: $0) }
    }
    
    func resized(toFill size: CGSize) -> UIImage? {
        return cgImage?.resized(toFill: size).flatMap { UIImage(cgImage: $0) }
    }
}
