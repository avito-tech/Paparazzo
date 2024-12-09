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
        
        if (presenting is PhotoLibraryV2ViewController
            || (presenting as? UINavigationController)?.topViewController is PhotoLibraryV2ViewController)
            && presented is CameraV3ViewController
        {
            return CameraV3PresentAnimator()
        }
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        if dismissed is NewCameraViewController {
            return CameraToPhotoLibraryTransitionAnimator()
        }
        if dismissed is CameraV3ViewController {
            return CameraV3DismissAnimator()
        }
        return nil
    }
}
