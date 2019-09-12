import UIKit

final class PhotoLibraryToCameraTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    static let shared = PhotoLibraryToCameraTransitioningDelegate()
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        if (presenting is PhotoLibraryV2ViewController
            || (presenting as? UINavigationController)?.topViewController is PhotoLibraryV2ViewController)
            && presented is NewCameraViewController
        {
            return PhotoLibraryToCameraTransitionAnimator()
        }
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        if dismissed is NewCameraViewController {
            return CameraToPhotoLibraryTransitionAnimator()
        }
        return nil
    }
}
