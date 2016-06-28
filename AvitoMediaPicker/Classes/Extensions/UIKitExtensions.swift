import UIKit

extension UICollectionView {
    
    func performBatchUpdates(updates: () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    func performNonAnimatedBatchUpdates(updates: (() -> Void)) {
        UIView.animateWithDuration(0) { 
            self.performBatchUpdates(updates, completion: nil)
        }
    }
}