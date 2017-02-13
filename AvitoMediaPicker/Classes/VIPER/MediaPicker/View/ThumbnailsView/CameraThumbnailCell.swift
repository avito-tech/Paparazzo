import UIKit

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
        
        let newOutputBinder = CameraOutputGLKBinder(imageOutput: parameters.imageOutput)
        
        if let previousOutputBinder = cameraOutputBinder {
            // AI-3326: костыль для iOS 8.
            // Удаляем предыдущую вьюху, как только будет нарисован первый фрейм новой вьюхи, иначе будет мелькание.
            newOutputBinder.onFrameDrawn = { [weak newOutputBinder] in
                newOutputBinder?.onFrameDrawn = nil
                DispatchQueue.main.async {
                    previousOutputBinder.view.removeFromSuperviewAfterFadingOut(withDuration: 0.25)
                }
            }
        }
        
        let view = newOutputBinder.view
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        insertSubview(view, belowSubview: cameraOutputBinder?.view ?? button)
        
        cameraOutputBinder = newOutputBinder
        
        // AI-3610: костыль для iPhone 4, чтобы не было белой рамки вокруг ячейки.
        // Если ставить clearColor, скругление углов теряется на iOS 9.
        self.backgroundColor = UIColor.white.withAlphaComponent(0.1)
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
