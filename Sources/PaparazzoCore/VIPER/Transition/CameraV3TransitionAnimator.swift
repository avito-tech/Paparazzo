import UIKit

final class CameraV3PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let animationDuration: TimeInterval = 0.2
    
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)?.photoLibraryViewController,
            let incomingViewController = transitionContext.viewController(forKey: .to) as? CameraV3ViewController,
            let incomingView = transitionContext.view(forKey: .to),
            let previewLayer = fromViewController.previewLayer
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let container = transitionContext.containerView
        container.addSubview(incomingView)
        incomingView.frame = CGRect(
            x: .zero,
            y: container.frame.height,
            width: container.bounds.width,
            height: container.bounds.height
        )
        
        fromViewController.setPreviewLayer(nil)
        
        UIView.transition(with: incomingView, duration: animationDuration, options: [.curveEaseOut], animations: {
            incomingView.frame.origin = .zero
            previewLayer.cornerRadius = 0
            incomingViewController.setPreviewLayer(previewLayer)
        }, completion: {
            transitionContext.completeTransition($0)
        })
    }
}

final class CameraV3DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let animationDuration: TimeInterval = 0.25
    
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? CameraV3ViewController,
            let incomingViewController = transitionContext.viewController(forKey: .to)?.photoLibraryViewController,
            let incomingView = transitionContext.view(forKey: .to),
            let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: true),
            let previewLayer = fromViewController.previewLayer
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let container = transitionContext.containerView
        container.addSubview(incomingView)
        container.addSubview(snapshot)
        
        fromViewController.setPreviewLayer(nil)
        
        UIView.transition(with: container, duration: animationDuration, options: [.curveEaseOut]) {
            snapshot.frame = CGRect(
                x: snapshot.bounds.origin.x,
                y: snapshot.bounds.size.height,
                width: snapshot.bounds.size.width,
                height: snapshot.bounds.size.height
            )
            previewLayer.cornerRadius = 6
            incomingViewController.setPreviewLayer(previewLayer)
        } completion: {
            snapshot.removeFromSuperview()
            transitionContext.completeTransition($0)
        }
    }
}

fileprivate extension UIViewController {
    var photoLibraryViewController: PhotoLibraryTransitionController? {
        self as? PhotoLibraryTransitionController
        ?? (self as? UINavigationController)?.topViewController as? PhotoLibraryTransitionController
    }
}
