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
            || (presenting as? UINavigationController)?.topViewController is PhotoLibraryV2ViewController) {
            if presented is CameraV3ViewController {
                return CameraV3PresentAnimator()
            } else if presented is MedicalBookCameraViewController {
                return MedicalBookCameraPresentAnimator()
            }
        }
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        if dismissed is CameraV3ViewController {
            return CameraV3DismissAnimator()
        } else if dismissed is MedicalBookCameraViewController {
            return MedicalBookCameraDismissAnimator()
        }
        
        return nil
    }
}
