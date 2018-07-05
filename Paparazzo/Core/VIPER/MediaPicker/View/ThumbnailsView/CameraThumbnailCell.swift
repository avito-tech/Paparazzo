import ImageSource
import UIKit

final class CameraThumbnailCell: UICollectionViewCell {
    
    private let button = UIButton()
    
    private var cameraOutputView: CameraOutputView?
    
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
        
        let newCameraOutputView = CameraOutputView(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation,
            isMetalEnabled: parameters.isMetalEnabled
        )
        
        newCameraOutputView.layer.cornerRadius = 6
        
        if UIDevice.systemVersionLessThan(version: "9.0"), let currentCameraOutputView = self.cameraOutputView {
            // AI-3326: костыль для iOS 8.
            // Удаляем предыдущую вьюху, как только будет нарисован первый фрейм новой вьюхи, иначе будет мелькание.
            newCameraOutputView.onFrameDraw = { [weak newCameraOutputView] in
                newCameraOutputView?.onFrameDraw = nil
                DispatchQueue.main.async {
                    currentCameraOutputView.removeFromSuperviewAfterFadingOut(withDuration: 0.25)
                }
            }
        } else {
            cameraOutputView?.removeFromSuperview()
        }
        
        insertSubview(newCameraOutputView, belowSubview: button)
        
        self.cameraOutputView = newCameraOutputView
        
        // AI-3610: костыль для iPhone 4, чтобы не было белой рамки вокруг ячейки.
        // Если ставить clearColor, скругление углов теряется на iOS 9.
        self.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    }
    
    func setOutputOrientation(_ orientation: ExifOrientation) {
        cameraOutputView?.orientation = orientation
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
        
        setAccessibilityId(.cameraThumbnailCell)
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
        
        let insets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
        
        cameraOutputView?.frame = UIEdgeInsetsInsetRect(bounds, insets)
        button.frame = bounds
    }
    
    // MARK: - Private
    
    private func adjustBorderColor() {
        layer.borderColor = selectedBorderColor?.cgColor
    }
}
