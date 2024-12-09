import UIKit

final class MaskCropperControlsView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MaskCropperUITheme
    
    // MARK: - Subviews
    
    private let discardButton = UIButton(type: .custom)
    private let confirmButton = UIButton(type: .custom)
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        addSubview(discardButton)
        addSubview(confirmButton)
        
        discardButton.addTarget(
            self,
            action: #selector(onDiscardTap(_:)),
            for: .touchUpInside
        )
        
        confirmButton.addTarget(
            self,
            action: #selector(onConfirmTap(_:)),
            for: .touchUpInside
        )
        
        setUpAccessibilityIdentifiers()
    }
    
    private func setUpAccessibilityIdentifiers() {
        discardButton.setAccessibilityId(.discardButton)
        confirmButton.setAccessibilityId(.confirmButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        discardButton.size = CGSize.minimumTapAreaSize
        discardButton.center = CGPoint(
            x: bounds.left + bounds.size.width * 0.25,
            y: bounds.bottom - 40
        )
        
        confirmButton.size = CGSize.minimumTapAreaSize
        confirmButton.center = CGPoint(
            x: bounds.right - bounds.size.width * 0.25,
            y: discardButton.centerY)
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        discardButton.setImage(
            theme.maskCropperDiscardPhotoIcon,
            for: .normal
        )
        confirmButton.setImage(
            theme.maskCropperConfirmPhotoIcon,
            for: .normal
        )
    }
    
    // MARK: - MaskCropperControlsView
    
    var onDiscardTap: (() -> ())?
    var onConfirmTap: (() -> ())?
    
    func setControlsEnabled(_ enabled: Bool) {
        discardButton.isEnabled = enabled
    }
    
    // MARK: - Actions
    @objc private func onDiscardTap(_ sender: UIButton) {
        onDiscardTap?()
    }
    
    @objc private func onConfirmTap(_ sender: UIButton) {
        onConfirmTap?()
    }
}
