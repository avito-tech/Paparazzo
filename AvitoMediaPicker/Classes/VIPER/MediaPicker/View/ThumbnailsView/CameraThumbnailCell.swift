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
        view.layer.cornerRadius = 6
        insertSubview(view, belowSubview: button)
        
        self.cameraOutputBinder = cameraOutputBinder
        self.backgroundColor = .white
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
        
        cameraOutputBinder?.view.frame = bounds.shrinked(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
        button.frame = bounds
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.cgColor
    }
}
