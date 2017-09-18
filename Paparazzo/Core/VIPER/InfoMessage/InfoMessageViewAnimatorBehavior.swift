import UIKit

protocol InfoMessageAnimatorBehavior {
    func configure(messageView: UIView, in container: UIView)
    func present(messageView: UIView, in container: UIView)
    func dismiss(messageView: UIView, in container: UIView)
}

final class DefaultInfoMessageAnimatorBehavior: InfoMessageAnimatorBehavior {
    
    func configure(messageView: UIView, in container: UIView) {
        messageView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        messageView.alpha = 0
        
        // Hardcoded, because the camera camera controls is located above all views on iPad
        var bottomInset: CGFloat = 20
        if UIDevice.current.userInterfaceIdiom == .pad {
            bottomInset = 154
        }
        messageView.bottom = container.height - bottomInset
        messageView.centerX = ceil(container.width / 2)
    }
    
    func present(messageView: UIView, in container: UIView) {
        messageView.alpha = 1
    }
    
    func dismiss(messageView: UIView, in container: UIView) {
        messageView.alpha = 0
    }
}

