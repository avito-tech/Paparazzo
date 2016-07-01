import UIKit
import AVFoundation

final class CameraThumbnailCell: UICollectionViewCell {
    
    private let button = UIButton()
    
    private let cameraOutputBinder = CameraOutputGLKBinder()
    private var cameraOutputView: UIView?
    
    var selectedBorderColor: UIColor? = .blueColor() {
        didSet {
            adjustBorderColor()
        }
    }
    
    func setCameraIcon(icon: UIImage?) {
        button.setImage(icon, forState: .Normal)
    }
    
    func setCameraIconTransform(transform: CGAffineTransform) {
        button.transform = transform
    }
    
    func setCaptureSession(session: AVCaptureSession) {
        
        let view = cameraOutputBinder.setUpWithAVCaptureSession(session)
        view.clipsToBounds = true
        
        insertSubview(view, belowSubview: button)
        cameraOutputView = view
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blackColor()
        
        button.tintColor = .whiteColor()
        button.userInteractionEnabled = false
        
        adjustBorderColor()
        
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewCell
    
    override var selected: Bool {
        didSet {
            layer.borderWidth = selected ? 4 : 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraOutputView?.frame = bounds
        button.frame = bounds
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.CGColor
    }
}
