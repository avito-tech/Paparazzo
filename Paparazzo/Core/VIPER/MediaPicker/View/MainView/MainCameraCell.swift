import UIKit

final class MainCameraCell: UICollectionViewCell {

    var cameraView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let cameraView = cameraView {
                addSubview(cameraView)
                setAccessibilityId(.mainCameraCell)
            }
        }
    }
    
    var cameraOverlayView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let cameraOverlayView = cameraOverlayView {
                addSubview(cameraOverlayView)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraView?.frame = contentView.bounds
        cameraOverlayView?.frame = contentView.bounds
    }
}
