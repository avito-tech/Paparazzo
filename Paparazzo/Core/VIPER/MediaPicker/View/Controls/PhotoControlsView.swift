import UIKit

final class PhotoControlsView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    // MARK: - Subviews
    
    private let removeButton = UIButton()
    private let cropButton = UIButton()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        removeButton.addTarget(
            self,
            action: #selector(onRemoveButtonTap(_:)),
            for: .touchUpInside
        )
        
        cropButton.addTarget(
            self,
            action: #selector(onCropButtonTap(_:)),
            for: .touchUpInside
        )
        
        addSubview(removeButton)
        addSubview(cropButton)    // в первой итерации не показываем
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeButton.size = CGSize.minimumTapAreaSize
        cropButton.size = CGSize.minimumTapAreaSize
        
        if cropButton.isHidden {
            removeButton.center = bounds.center
        } else {
            removeButton.center = CGPoint(x: bounds.left + bounds.size.width * 0.25, y: bounds.centerY)
            cropButton.center = CGPoint(x: bounds.right - bounds.size.width * 0.25, y: bounds.centerY)
        }
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        removeButton.setImage(theme.removePhotoIcon, for: .normal)
        cropButton.setImage(theme.cropPhotoIcon, for: .normal)
    }
    
    // MARK: - PhotoControlsView
    
    var onRemoveButtonTap: (() -> ())?
    var onCropButtonTap: (() -> ())?
    var onCameraButtonTap: (() -> ())?
    
    func setControlsTransform(_ transform: CGAffineTransform) {
        removeButton.transform = transform
        cropButton.transform = transform
    }
    
    func setShowsCropButton(_ showsCropButton: Bool) {
        cropButton.isHidden = !showsCropButton
        setNeedsLayout()
    }
    
    // MARK: - Private
    
    @objc private func onRemoveButtonTap(_: UIButton) {
        onRemoveButtonTap?()
    }
    
    @objc private func onCropButtonTap(_: UIButton) {
        onCropButtonTap?()
    }
}
