import UIKit

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