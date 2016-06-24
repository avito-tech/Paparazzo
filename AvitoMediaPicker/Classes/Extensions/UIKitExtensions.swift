import UIKit

extension UICollectionView {
    
    func performNonAnimatedBatchUpdates(updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(0) { 
            self.performBatchUpdates(updates, completion: completion)
        }
    }
}