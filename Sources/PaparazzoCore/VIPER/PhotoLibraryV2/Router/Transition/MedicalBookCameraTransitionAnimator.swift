import UIKit

final class MedicalBookCameraPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let animationDuration: TimeInterval = Spec.animationDuratuion
    
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)?.photoLibraryV2ViewController,
            let incomingViewController = transitionContext.viewController(forKey: .to) as? MedicalBookCameraViewController,
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

final class MedicalBookCameraDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let animationDuration: TimeInterval = Spec.animationDuratuion
    
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? MedicalBookCameraViewController,
            let incomingViewController = transitionContext.viewController(forKey: .to)?.photoLibraryV2ViewController,
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
            previewLayer.cornerRadius = 0
            incomingViewController.setPreviewLayer(previewLayer)
        } completion: {
            snapshot.removeFromSuperview()
            transitionContext.completeTransition($0)
        }
    }
}

private enum Spec {
    static let animationDuratuion: TimeInterval = 0.25
}

private extension UIViewController {
    var photoLibraryV2ViewController: PhotoLibraryV2ViewController? {
        self as? PhotoLibraryV2ViewController
        ?? (self as? UINavigationController)?.topViewController as? PhotoLibraryV2ViewController
    }
}
