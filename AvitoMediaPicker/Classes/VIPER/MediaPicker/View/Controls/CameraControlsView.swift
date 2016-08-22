import UIKit
import AvitoDesignKit
import JNWSpringAnimation

final class CameraControlsView: UIView {
    
    var onShutterButtonTap: (() -> ())?
    var onPhotoLibraryButtonTap: (() -> ())?
    var onCameraToggleButtonTap: (() -> ())?
    var onFlashToggle: (Bool -> ())?
    
    // MARK: - Subviews
    
    private let photoView = UIImageView()
    private let shutterButton = UIButton()
    private let cameraToggleButton = UIButton()
    private let flashButton = UIButton()
    
    // MARK: - Constants
    
    private let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    
    private let shutterButtonMinDiameter = CGFloat(44)
    private let shutterButtonMaxDiameter = CGFloat(64)
    
    private let photoViewDiameter = CGFloat(44)
    private var photoViewPlaceholder: UIImage?
    
    // Параметры анимации кнопки съемки (подобраны ikarpov'ым)
    private let shutterAnimationMinScale = CGFloat(0.842939)
    private let shutterAnimationDamping = CGFloat(18.6888)
    private let shutterAnimationStiffness = CGFloat(366.715)
    private let shutterAnimationMass = CGFloat(0.475504)
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        photoView.backgroundColor = .lightGrayColor()
        photoView.contentMode = .ScaleAspectFill
        photoView.layer.cornerRadius = photoViewDiameter / 2
        photoView.clipsToBounds = true
        photoView.userInteractionEnabled = true
        photoView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(CameraControlsView.onPhotoViewTap(_:))
        ))
        
        shutterButton.backgroundColor = .blueColor()
        shutterButton.clipsToBounds = false
        shutterButton.addTarget(
            self,
            action: #selector(CameraControlsView.onShutterButtonTouchDown(_:)),
            forControlEvents: .TouchDown
        )
        shutterButton.addTarget(
            self,
            action: #selector(CameraControlsView.onShutterButtonTouchUp(_:)),
            forControlEvents: .TouchUpInside
        )
        
        flashButton.addTarget(
            self,
            action: #selector(CameraControlsView.onFlashButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        cameraToggleButton.addTarget(
            self,
            action: #selector(CameraControlsView.onCameraToggleButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        addSubview(photoView)
        addSubview(shutterButton)
        addSubview(flashButton)
        addSubview(cameraToggleButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentHeight = bounds.shrinked(insets).size.height
        let shutterButtonDiameter = max(shutterButtonMinDiameter, min(shutterButtonMaxDiameter, contentHeight))
        let shutterButtonSize = CGSize(width: shutterButtonDiameter, height: shutterButtonDiameter)
        
        shutterButton.frame = CGRect(origin: .zero, size: shutterButtonSize)
        shutterButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        shutterButton.layer.cornerRadius = shutterButtonDiameter / 2
        
        flashButton.size = CGSize.minimumTapAreaSize
        flashButton.centerX = bounds.right - 30
        flashButton.centerY = bounds.centerY
        
        cameraToggleButton.size = CGSize.minimumTapAreaSize
        cameraToggleButton.centerX = flashButton.centerX - 54
        cameraToggleButton.centerY = flashButton.centerY
        
        photoView.size = CGSize(width: photoViewDiameter, height: photoViewDiameter)
        photoView.left = bounds.left + insets.left
        photoView.centerY = bounds.centerY
    }
    
    // MARK: - CameraControlsView
    
    func setControlsTransform(transform: CGAffineTransform) {
        flashButton.transform = transform
        cameraToggleButton.transform = transform
        photoView.transform = transform
    }
    
    func setLatestPhotoLibraryItemImage(imageSource: ImageSource?) {
        photoView.setImage(
            fromSource: imageSource,
            size: CGSize(width: photoViewDiameter, height: photoViewDiameter),
            placeholder: photoViewPlaceholder,
            placeholderDeferred: false
        )
    }
    
    func setCameraControlsEnabled(enabled: Bool) {
        shutterButton.enabled = enabled
        cameraToggleButton.enabled = enabled
        flashButton.enabled = enabled
        
        adjustShutterButtonColor()
    }
    
    func setFlashButtonVisible(visible: Bool) {
        flashButton.hidden = !visible
    }
    
    func setFlashButtonOn(isOn: Bool) {
        flashButton.selected = isOn
    }
    
    func setCameraToggleButtonVisible(visible: Bool) {
        cameraToggleButton.hidden = !visible
    }
    
    func setShutterButtonEnabled(enabled: Bool) {
        shutterButton.enabled = enabled
    }
    
    func setPhotoLibraryButtonEnabled(enabled: Bool) {
        photoView.userInteractionEnabled = enabled
    }
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {
        
        self.theme = theme

        flashButton.setImage(theme.flashOffIcon, forState: .Normal)
        flashButton.setImage(theme.flashOnIcon, forState: .Selected)

        cameraToggleButton.setImage(theme.cameraToggleIcon, forState: .Normal)
        
        photoViewPlaceholder = theme.photoPeepholePlaceholder
        
        adjustShutterButtonColor()
    }
    
    // MARK: - Private
    
    private var theme: MediaPickerRootModuleUITheme?
    
    @objc private func onShutterButtonTouchDown(button: UIButton) {
        animateShutterButtonToScale(shutterAnimationMinScale)
    }
    
    @objc private func onShutterButtonTouchUp(button: UIButton) {
        animateShutterButtonToScale(1)
        onShutterButtonTap?()
    }
    
    @objc private func onPhotoViewTap(tapRecognizer: UITapGestureRecognizer) {
        onPhotoLibraryButtonTap?()
    }
    
    @objc private func onFlashButtonTap(button: UIButton) {
        button.selected = !button.selected
        onFlashToggle?(button.selected)
    }
    
    @objc private func onCameraToggleButtonTap(button: UIButton) {
        onCameraToggleButtonTap?()
    }
    
    private func animateShutterButtonToScale(_ scale: CGFloat) {
        
        // Тут пишут о том, чем стандартная spring-анимация плоха:
        // https://medium.com/@flyosity/your-spring-animations-are-bad-and-it-s-probably-apple-s-fault-784932e51733#.jr5m2x2vl
        
        let keyPath = "transform.scale"
        
        let animation = JNWSpringAnimation(keyPath: keyPath)
        animation.damping = shutterAnimationDamping
        animation.stiffness = shutterAnimationStiffness
        animation.mass = shutterAnimationMass
        
        let layer = shutterButton.layer.presentationLayer() ?? shutterButton.layer
        
        animation.fromValue = layer.valueForKeyPath(keyPath)
        animation.toValue = scale
        
        shutterButton.layer.setValue(animation.toValue, forKeyPath: keyPath)
        
        shutterButton.layer.addAnimation(animation, forKey: keyPath)
    }
    
    private func adjustShutterButtonColor() {
        shutterButton.backgroundColor = shutterButton.enabled ? theme?.shutterButtonColor : theme?.shutterButtonDisabledColor
    }
}
