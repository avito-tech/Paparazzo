import ImageSource
import UIKit
#if canImport(JNWSpringAnimation)
import JNWSpringAnimation
#endif

final class CameraControlsView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    var onShutterButtonTap: (() -> ())?
    var onPhotoLibraryButtonTap: (() -> ())?
    var onCameraToggleButtonTap: (() -> ())?
    var onFlashToggle: ((Bool) -> ())?
    
    // MARK: - Subviews
    
    private let photoView = UIImageView()
    private let photoOverlayView = UIView()
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
        
        backgroundColor = .white
        
        photoView.backgroundColor = .lightGray
        photoView.contentMode = .scaleAspectFill
        photoView.layer.cornerRadius = photoViewDiameter / 2
        photoView.clipsToBounds = true
        photoView.isUserInteractionEnabled = true
        photoView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(onPhotoViewTap(_:))
        ))
        
        photoOverlayView.backgroundColor = .black
        photoOverlayView.alpha = 0.04
        photoOverlayView.layer.cornerRadius = photoViewDiameter / 2
        photoOverlayView.clipsToBounds = true
        photoOverlayView.isUserInteractionEnabled = false
        
        shutterButton.backgroundColor = .blue
        shutterButton.clipsToBounds = false
        shutterButton.addTarget(
            self,
            action: #selector(onShutterButtonTouchDown(_:)),
            for: .touchDown
        )
        shutterButton.addTarget(
            self,
            action: #selector(onShutterButtonTouchUp(_:)),
            for: .touchUpInside
        )
        
        flashButton.addTarget(
            self,
            action: #selector(onFlashButtonTap(_:)),
            for: .touchUpInside
        )
        
        cameraToggleButton.addTarget(
            self,
            action: #selector(onCameraToggleButtonTap(_:)),
            for: .touchUpInside
        )
        
        addSubview(photoView)
        addSubview(photoOverlayView)
        addSubview(shutterButton)
        addSubview(flashButton)
        addSubview(cameraToggleButton)
        
        setUpAccessibilityIdentifiers()
    }
    
    private func setUpAccessibilityIdentifiers() {
        photoView.setAccessibilityId(.photoView)
        shutterButton.setAccessibilityId(.shutterButton)
        cameraToggleButton.setAccessibilityId(.cameraToggleButton)
        flashButton.setAccessibilityId(.flashButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentHeight = bounds.inset(by: insets).size.height
        let shutterButtonDiameter = max(shutterButtonMinDiameter, min(shutterButtonMaxDiameter, contentHeight))
        let shutterButtonSize = CGSize(width: shutterButtonDiameter, height: shutterButtonDiameter)
        let centerY = bounds.centerY
        
        shutterButton.frame = CGRect(origin: .zero, size: shutterButtonSize)
        shutterButton.center = CGPoint(x: bounds.midX, y: centerY)
        shutterButton.layer.cornerRadius = shutterButtonDiameter / 2
        
        flashButton.size = CGSize.minimumTapAreaSize
        flashButton.centerX = bounds.right - 30
        flashButton.centerY = centerY
        
        cameraToggleButton.size = CGSize.minimumTapAreaSize
        cameraToggleButton.centerX = flashButton.centerX - 54
        cameraToggleButton.centerY = flashButton.centerY
        
        photoView.size = CGSize(width: photoViewDiameter, height: photoViewDiameter)
        photoView.left = bounds.left + insets.left
        photoView.centerY = centerY
        
        photoOverlayView.frame = photoView.frame
    }
    
    // MARK: - CameraControlsView
    
    func setControlsTransform(_ transform: CGAffineTransform) {
        flashButton.transform = transform
        cameraToggleButton.transform = transform
        photoView.transform = transform
    }
    
    func setLatestPhotoLibraryItemImage(_ imageSource: ImageSource?) {
        photoView.setImage(
            fromSource: imageSource,
            size: CGSize(width: photoViewDiameter, height: photoViewDiameter),
            placeholder: photoViewPlaceholder,
            placeholderDeferred: false
        )
    }
    
    func setCameraControlsEnabled(_ enabled: Bool) {
        shutterButton.isEnabled = enabled
        cameraToggleButton.isEnabled = enabled
        flashButton.isEnabled = enabled
        
        adjustShutterButtonColor()
    }
    
    func setFlashButtonVisible(_ visible: Bool) {
        flashButton.isHidden = !visible
    }
    
    func setFlashButtonOn(_ isOn: Bool) {
        flashButton.isSelected = isOn
    }
    
    func setCameraToggleButtonVisible(_ visible: Bool) {
        cameraToggleButton.isHidden = !visible
    }
    
    func setShutterButtonEnabled(_ enabled: Bool) {
        shutterButton.isEnabled = enabled
    }
    
    func setPhotoLibraryButtonEnabled(_ enabled: Bool) {
        photoView.isUserInteractionEnabled = enabled
    }
    
    func setPhotoLibraryButtonVisible(_ visible: Bool) {
        photoOverlayView.isHidden = !visible
        photoView.isHidden = !visible
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        
        self.theme = theme

        backgroundColor = theme.cameraControlsViewBackgroundColor
        
        flashButton.setImage(theme.flashOffIcon, for: .normal)
        flashButton.setImage(theme.flashOnIcon, for: .selected)

        cameraToggleButton.setImage(theme.cameraToggleIcon, for: .normal)
        
        photoViewPlaceholder = theme.photoPeepholePlaceholder
        
        adjustShutterButtonColor()
    }
    
    // MARK: - Private
    
    private var theme: MediaPickerRootModuleUITheme?
    
    @objc private func onShutterButtonTouchDown(_ button: UIButton) {
        animateShutterButtonToScale(shutterAnimationMinScale)
    }
    
    @objc private func onShutterButtonTouchUp(_ button: UIButton) {
        animateShutterButtonToScale(1)
        onShutterButtonTap?()
    }
    
    @objc private func onPhotoViewTap(_ tapRecognizer: UITapGestureRecognizer) {
        onPhotoLibraryButtonTap?()
    }
    
    @objc private func onFlashButtonTap(_ button: UIButton) {
        button.isSelected = !button.isSelected
        onFlashToggle?(button.isSelected)
    }
    
    @objc private func onCameraToggleButtonTap(_ button: UIButton) {
        onCameraToggleButtonTap?()
    }
    
    private func animateShutterButtonToScale(_ scale: CGFloat) {
        
        // Тут пишут о том, чем стандартная spring-анимация плоха:
        // https://medium.com/@flyosity/your-spring-animations-are-bad-and-it-s-probably-apple-s-fault-784932e51733#.jr5m2x2vl
        
        let keyPath = "transform.scale"
        
        guard let animation = JNWSpringAnimation(keyPath: keyPath) else {
            shutterButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            return
        }
        
        animation.damping = shutterAnimationDamping
        animation.stiffness = shutterAnimationStiffness
        animation.mass = shutterAnimationMass
        
        let layer = shutterButton.layer.presentation() ?? shutterButton.layer
        
        animation.fromValue = layer.value(forKeyPath: keyPath)
        animation.toValue = scale
        
        shutterButton.layer.setValue(animation.toValue, forKeyPath: keyPath)
        
        shutterButton.layer.add(animation, forKey: keyPath)
    }
    
    private func adjustShutterButtonColor() {
        shutterButton.backgroundColor = shutterButton.isEnabled ? theme?.shutterButtonColor : theme?.shutterButtonDisabledColor
    }
}
