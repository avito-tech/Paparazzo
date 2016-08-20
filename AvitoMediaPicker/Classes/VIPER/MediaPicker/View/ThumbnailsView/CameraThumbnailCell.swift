import UIKit
import AVFoundation

final class CameraThumbnailCell: UICollectionViewCell {
    
    private let button = UIButton()
    
    private var cameraOutputBinder: CameraOutputGLKBinder?
    
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
    
    func setOutputParameters(parameters: CameraOutputParameters) {
        
        let cameraOutputBinder = CameraOutputGLKBinder(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation
        )
        
        let view = cameraOutputBinder.view
        view.clipsToBounds = true
        insertSubview(view, belowSubview: button)
        
        self.cameraOutputBinder = cameraOutputBinder
    }
    
    func setOutputOrientation(orientation: ExifOrientation) {
        cameraOutputBinder?.orientation = orientation
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
        
        cameraOutputBinder?.view.frame = bounds
        button.frame = bounds
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.CGColor
    }
}
