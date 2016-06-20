import UIKit.UICollectionView
import AVFoundation

final class CameraCell: UICollectionViewCell {
    
    private let button = UIButton()
    
    var selectedBorderColor: UIColor = .blueColor() {
        didSet {
            adjustBorderColor()
        }
    }
    
    func setCameraIcon(icon: UIImage?) {
        button.setImage(icon, forState: .Normal)
    }
    
    func setCaptureSession(session: AVCaptureSession) {
        
        // TODO
        
        // This steals camera output from the main view
//        let capturePreviewLayer = AVCaptureVideoPreviewLayer(session: session)
//        capturePreviewLayer.backgroundColor = UIColor.blackColor().CGColor
//        capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect
//        layer.insertSublayer(capturePreviewLayer, atIndex: 0)
//
//        self.capturePreviewLayer?.removeFromSuperlayer()
//        self.capturePreviewLayer = capturePreviewLayer
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
        
        button.frame = bounds
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor.CGColor
    }
}
