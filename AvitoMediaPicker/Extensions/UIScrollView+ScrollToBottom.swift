import UIKit.UIScrollView

extension UIScrollView {
    
    func scrollToBottom() {
        
        layoutIfNeeded()
        
        contentOffset = CGPoint(
            x: 0,
            y: bounds.y + contentSize.height + contentInset.top - bounds.size.height
        )
    }
}