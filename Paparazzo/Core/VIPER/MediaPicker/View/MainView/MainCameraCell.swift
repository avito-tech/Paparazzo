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

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraView?.frame = contentView.bounds
    }
}