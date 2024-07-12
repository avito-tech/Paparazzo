import UIKit

final class PhotoLibraryToCameraTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard
            let fromViewController = photoLibraryViewController(from: transitionContext.viewController(forKey: .from)),
            let fromView = transitionContext.view(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) as? NewCameraViewController,
            let toView = transitionContext.view(forKey: .to),
            let previewLayer = fromViewController.previewLayer
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let initialFrame = containerView.convert(
            fromViewController.previewFrame(forBounds: containerView.bounds),
            from: fromViewController.view
        )
        
        fromViewController.setPreviewLayer(nil)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        containerView.layer.addSublayer(previewLayer)
        previewLayer.frame = initialFrame
        previewLayer.presentation()?.frame = initialFrame
        CATransaction.commit()
        
        containerView.insertSubview(toView, aboveSubview: fromView)
        toView.frame = containerView.bounds
        toView.layer.opacity = 0
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(transitionDuration(using: transitionContext))
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        CATransaction.setCompletionBlock {
            let success = !transitionContext.transitionWasCancelled
            
            toViewController.setPreviewLayer(previewLayer)
            
            // TODO: After a failed presentation or successful dismissal, remove the view.
            
            transitionContext.completeTransition(success)
        }
        
        // Animating camera preview layer
        previewLayer.frame = toViewController.previewFrame(forBounds: containerView.bounds)
        
        let previewLayerCornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        previewLayerCornerRadiusAnimation.fromValue = 6  // TODO: брать из view controller'а
        previewLayerCornerRadiusAnimation.toValue = 0    // TODO: брать из view controller'а
        previewLayer.cornerRadius = 0
        previewLayer.add(previewLayerCornerRadiusAnimation, forKey: "cornerRadius")
        
        // Animating target view controller opacity
        let toViewOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        toViewOpacityAnimation.fromValue = 0
        toViewOpacityAnimation.toValue = 1
        toView.layer.opacity = 1
        toView.layer.add(toViewOpacityAnimation, forKey: "opacity")
        
        CATransaction.commit()
    }
    
    private func photoLibraryViewController(from viewController: UIViewController?) -> PhotoLibraryV2ViewController? {
        return viewController as? PhotoLibraryV2ViewController
            ?? (viewController as? UINavigationController)?.topViewController as? PhotoLibraryV2ViewController
    }
}

