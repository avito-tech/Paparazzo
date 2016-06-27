import UIKit

extension UICollectionView {
    
    func performBatchUpdates(updates: () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    func performNonAnimatedBatchUpdates(updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(0) { 
            self.performBatchUpdates(updates, completion: completion)
        }
    }
}