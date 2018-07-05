import UIKit
import ImageSource

class PhotoLibraryCameraView: UICollectionReusableView {
    
    // MARK: - Subviews
    
    private var cameraOutputView: CameraOutputView?
    private var dimView = UIView()
    private let button = UIButton()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        layer.cornerRadius = 6
        layer.rasterizationScale = UIScreen.main.nativeScale
        layer.shouldRasterize = true
        layer.masksToBounds = true
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        
        addSubview(dimView)
        
        button.tintColor = .white
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        
        addSubview(button)
        
        setAccessibilityId(.cameraInLibraryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PhotoLibraryCameraView
    
    var onTap: (() -> ())?
    
    func setCameraIcon(_ icon: UIImage?) {
        button.setImage(icon, for: .normal)
    }
    
    func setOutputParameters(_ parameters: CameraOutputParameters) {
        
        let newCameraOutputView = CameraOutputView(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation,
            isMetalEnabled: parameters.isMetalEnabled
        )
        
        newCameraOutputView.layer.cornerRadius = 6
        cameraOutputView?.removeFromSuperview()
        
        insertSubview(newCameraOutputView, belowSubview: button)
        
        self.cameraOutputView = newCameraOutputView
    }
    
    func setOutputOrientation(_ orientation: ExifOrientation) {
        cameraOutputView?.orientation = orientation
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
        
        cameraOutputView?.frame = bounds
        dimView.frame = bounds
        button.frame = bounds
    }
    
    // MARK: - Private
    
    @objc private func onButtonTap(_ sender: UIButton) {
        onTap?()
    }
}
