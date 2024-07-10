import Marshroute

final class NonAnimatedPushAnimator: NavigationTransitionsAnimator {
    override func animatePerformingTransition(animationContext context: PushAnimationContext) {
        shouldAnimate = false
        super.animatePerformingTransition(animationContext: context)
    }
    
    override func animateUndoingTransition(animationContext context: PopAnimationContext) {
        shouldAnimate = false
        super.animateUndoingTransition(animationContext: context)
    }
}
