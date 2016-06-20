import UIKit.UICollectionView
import AVFoundation

final class CameraCell: UICollectionViewCell {
    
    private let button = UIButton()
    
    var selectedBorderColor: UIColor = .blueColor() {
        didSet {
            adjustBorderColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blackColor()
        
        button.tintColor = .whiteColor()
        button.userInteractionEnabled = false
        
        adjustBorderColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var selected: Bool {
        didSet {
            layer.borderWidth = selected ? 4 : 0
        }
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor.CGColor
    }
}
