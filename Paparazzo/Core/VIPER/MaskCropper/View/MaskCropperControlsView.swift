import UIKit

final class MaskCropperControlsView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MaskCropperUITheme
    
    // MARK: - Subviews
    
     private let discardButton = UIButton(type: .custom)
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        addSubview(discardButton)
        
        discardButton.addTarget(
            self,
            action: #selector(onDiscardTap(_:)),
            for: .touchUpInside
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        discardButton.size = CGSize(
            width: 30,
            height: 30
        )
        
        discardButton.centerX = centerX
        discardButton.bottom = height - 22
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        discardButton.setImage(
            theme.maskCropperDiscardPhotoIcon,
            for: .normal
        )
    }
    
    // MARK: - MaskCropperControlsView
    
    var onDiscardTap: (() -> ())?
    
    func setControlsEnabled(_ enabled: Bool) {
        discardButton.isEnabled = enabled
    }
    
    // MARK: - Actions
    @objc private func onDiscardTap(_ sender: UIButton) {
        onDiscardTap?()
    }
}
