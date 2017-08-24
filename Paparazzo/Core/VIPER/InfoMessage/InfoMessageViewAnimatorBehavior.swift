import UIKit

protocol InfoMessageAnimatorBehavior {
    func configure(messageView: UIView, in container: UIView)
    func present(messageView: UIView, in container: UIView)
    func dismiss(messageView: UIView, in container: UIView)
}

final class DefaultInfoMessageAnimatorBehavior: InfoMessageAnimatorBehavior {
    
    func configure(messageView: UIView, in container: UIView) {
        messageView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        messageView.top = container.bottom
        messageView.left = container.left
    }
    
    func present(messageView: UIView, in container: UIView) {
        messageView.bottom = container.height
    }
    
    func dismiss(messageView: UIView, in container: UIView) {
        messageView.top = container.bottom
    }
}

