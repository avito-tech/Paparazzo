import UIKit.UIScrollView

extension UIScrollView {
    
    func scrollToBottom() {
        
        layoutIfNeeded()

        let minimumYOffset: CGFloat
        if #available(iOS 11.0, *) {
            minimumYOffset = -safeAreaInsets.top
        } else {
            minimumYOffset = -contentInset.top
        }

        contentOffset = CGPoint(
            x: 0,
            y: max(minimumYOffset, bounds.y + contentSize.height + contentInset.top - bounds.size.height)
        )
    }
}
