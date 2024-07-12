import UIKit

final class CameraToPhotoLibraryTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let untypedFromViewController = transitionContext.viewController(forKey: .to)
        
        let libraryViewController1 = untypedFromViewController as? PhotoLibraryV2ViewController
        let libraryViewController2 =
            (untypedFromViewController as? UINavigationController)?.topViewController as? PhotoLibraryV2ViewController
        
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? NewCameraViewController,
            let fromView = transitionContext.view(forKey: .from),
            let toViewController = libraryViewController1 ?? libraryViewController2,
            let toView = transitionContext.view(forKey: .to),
            let previewLayer = fromViewController.previewLayer
            else {
                // TODO: transition as usual
                transitionContext.completeTransition(false /* TODO */)
                return
        }
        
        let initialFrame = containerView.convert(
            fromViewController.previewFrame(forBounds: containerView.bounds),  // TODO: параметр не нужен
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
        previewLayerCornerRadiusAnimation.fromValue = 0  // TODO: брать из view controller'а
        previewLayerCornerRadiusAnimation.toValue = 6    // TODO: брать из view controller'а
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
}
