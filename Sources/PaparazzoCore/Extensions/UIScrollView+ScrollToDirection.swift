import UIKit.UIScrollView

extension UIScrollView {
    
    func scrollToBottom() {
        
        layoutIfNeeded()

        let minimumYOffset = -max(paparazzoSafeAreaInsets.top, contentInset.top)

        contentOffset = CGPoint(
            x: 0,
            y: max(minimumYOffset, bounds.y + contentSize.height + contentInset.top - bounds.size.height)
        )
    }
    
    func scrollToTop() {
        
        layoutIfNeeded()
        
        contentOffset = CGPoint(
            x: 0,
            y: -max(paparazzoSafeAreaInsets.top, contentInset.top)
        )
    }
}
