import UIKit
import AvitoDesignKit

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
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        photoView.backgroundColor = .lightGrayColor()
        photoView.layer.cornerRadius = photoViewDiameter / 2
        photoView.clipsToBounds = true
        photoView.userInteractionEnabled = true
        photoView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(CameraControlsView.onPhotoViewTap(_:))
        ))
        
        shutterButton.backgroundColor = .blueColor()
        shutterButton.addTarget(
            self,
            action: #selector(CameraControlsView.onShutterButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        flashButton.hidden = true
        flashButton.addTarget(
            self,
            action: #selector(CameraControlsView.onFlashButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
//        cameraToggleButton.hidden = true   // TODO: по умолчанию кнопка должна быть скрыта
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
        
        let flashButtonSize = flashButton.sizeThatFits(bounds.size)
        flashButton.size = CGSize(width: flashButtonSize.width, height: flashButtonSize.width)
        flashButton.right = bounds.right - insets.right
        flashButton.centerY = bounds.centerY
        
        cameraToggleButton.sizeToFit()
        cameraToggleButton.centerY = flashButton.centerY
        cameraToggleButton.right = flashButton.left - 25
        
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
    
    func setLatestPhotoLibraryItemImage(image: ImageSource?) {
        let thumbnailSize = CGSize(width: photoViewDiameter, height: photoViewDiameter)
        photoView.setImage(image, size: thumbnailSize)
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
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {

        shutterButton.backgroundColor = theme.shutterButtonColor

        flashButton.setImage(theme.flashOffIcon, forState: .Normal)
        flashButton.setImage(theme.flashOnIcon, forState: .Selected)

        cameraToggleButton.setImage(theme.cameraToggleIcon, forState: .Normal)
    }
    
    // MARK: - Private
    
    @objc private func onShutterButtonTap(button: UIButton) {
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
}
