import UIKit
import AVFoundation

final class CameraThumbnailCell: UICollectionViewCell {
    
    private let button = UIButton()
    
    private var cameraOutputBinder: CameraOutputGLKBinder?
    
    var selectedBorderColor: UIColor? = .blue {
        didSet {
            adjustBorderColor()
        }
    }
    
    func setCameraIcon(_ icon: UIImage?) {
        button.setImage(icon, for: .normal)
    }
    
    func setCameraIconTransform(_ transform: CGAffineTransform) {
        button.transform = transform
    }
    
    func setOutputParameters(_ parameters: CameraOutputParameters) {
        
        let cameraOutputBinder = CameraOutputGLKBinder(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation
        )
        
        let view = cameraOutputBinder.view
        view.clipsToBounds = true
        insertSubview(view, belowSubview: button)
        
        self.cameraOutputBinder = cameraOutputBinder
    }
    
    func setOutputOrientation(_ orientation: ExifOrientation) {
        cameraOutputBinder?.orientation = orientation
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        
        adjustBorderColor()
        
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewCell
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 4 : 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraOutputBinder?.view.frame = bounds
        button.frame = bounds
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.cgColor
    }
}
