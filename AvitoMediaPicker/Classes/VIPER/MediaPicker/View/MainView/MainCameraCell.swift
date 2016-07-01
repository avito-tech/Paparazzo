import UIKit

final class MainCameraCell: UICollectionViewCell {

    var cameraView: UIView? {
        didSet {
            if cameraView !== oldValue {
                oldValue?.removeFromSuperview()
                
                if let cameraView = cameraView {
                    addSubview(cameraView)
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraView?.frame = contentView.bounds
    }
}