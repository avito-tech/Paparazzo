import UIKit

final class PhotoControlsView: UIView, ThemeConfigurable {
    
    struct ModeOptions: OptionSet {
        let rawValue: Int
        
        static let hasRemoveButton  = ModeOptions(rawValue: 1 << 0)
        static let hasAutocorrectButton  = ModeOptions(rawValue: 1 << 1)
        static let hasCropButton = ModeOptions(rawValue: 1 << 2)
        static let hasAutoEnhanceButton = ModeOptions(rawValue: 1 << 3)
        
        static let allButtons: ModeOptions = [.hasRemoveButton, .hasAutocorrectButton, .hasCropButton, .hasAutoEnhanceButton]
    }
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    // MARK: - Subviews
    
    private let removeButton = UIButton()
    private let autocorrectButton = UIButton()
    private let cropButton = UIButton()
    private let autoEnhanceButton = UIButton()
    
    private var buttons = [UIButton]()
    private var theme: ThemeType?
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        self.mode = [.hasRemoveButton, .hasCropButton]
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        removeButton.addTarget(
            self,
            action: #selector(onRemoveButtonTap(_:)),
            for: .touchUpInside
        )
        
        autocorrectButton.addTarget(
            self,
            action: #selector(onAutocorrectButtonTap(_:)),
            for: .touchUpInside
        )
        
        cropButton.addTarget(
            self,
            action: #selector(onCropButtonTap(_:)),
            for: .touchUpInside
        )
        
        autoEnhanceButton.addTarget(
            self,
            action: #selector(onAutoEnhanceButtonTap(_:)),
            for: .touchUpInside
        )
        
        addSubview(removeButton)
        addSubview(autocorrectButton)
        addSubview(autoEnhanceButton)
        addSubview(cropButton)
        
        buttons = [removeButton, autocorrectButton, autoEnhanceButton, cropButton]
        
        setUpAccessibilityIdentifiers()
    }
    
    private func setUpAccessibilityIdentifiers() {
        removeButton.setAccessibilityId(.removeButton)
        autocorrectButton.setAccessibilityId(.autocorrectButton)
        cropButton.setAccessibilityId(.cropButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let visibleButtons = buttons.filter { $0.isHidden == false }
        visibleButtons.enumerated().forEach { index, button in
            button.size = CGSize.minimumTapAreaSize
            button.center = CGPoint(
                x: (width * (2.0 * CGFloat(index) + 1.0)) / (2.0 * CGFloat(visibleButtons.count)),
                y: bounds.centerY
            )
        }
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        backgroundColor = theme.photoControlsViewBackgroundColor
        removeButton.setImage(theme.removePhotoIcon, for: .normal)
        autocorrectButton.setImage(theme.autocorrectPhotoIcon, for: .normal)
        cropButton.setImage(theme.cropPhotoIcon, for: .normal)
        autoEnhanceButton.setImage(theme.autoEnhanceImageIcon, for: .normal)
        
        for button in buttons {
            button.tintColor = theme.mediaPickerIconColor
        }
        
        for button in buttons {
            let highlightedImage = button
                .image(for: .normal)?
                .withTintColor(theme.buttonGrayHighlightedColor, renderingMode: .alwaysOriginal)
            button.setImage(highlightedImage, for: .highlighted)
        }
    }
    
    // MARK: - PhotoControlsView
    
    var onRemoveButtonTap: (() -> ())?
    var onAutocorrectButtonTap: (() -> ())?
    var onCropButtonTap: (() -> ())?
    var onCameraButtonTap: (() -> ())?
    var onAutoEnhanceButtonTap: (() -> ())?
    
    var mode: ModeOptions {
        didSet {
            removeButton.isHidden = !mode.contains(.hasRemoveButton)
            autocorrectButton.isHidden = !mode.contains(.hasAutocorrectButton)
            cropButton.isHidden = !mode.contains(.hasCropButton)
            autoEnhanceButton.isHidden = !mode.contains(.hasAutoEnhanceButton)
            setNeedsLayout()
        }
    }
    
    func setControlsTransform(_ transform: CGAffineTransform) {
        removeButton.transform = transform
        autocorrectButton.transform = transform
        cropButton.transform = transform
        autoEnhanceButton.transform = transform
    }
    
    func setAutocorrectButtonSelected(_ selected: Bool) {
        let color = selected ? theme?.mediaPickerIconActiveColor : theme?.mediaPickerIconColor
        autocorrectButton.tintColor = color
    }
    
    func setAutoEnhanceButtonStatus(_ status: MediaPickerAutoEnhanceStatus) {
        var color: UIColor?
        autoEnhanceButton.isUserInteractionEnabled = true

        switch status {
        case .original:
            color = theme?.mediaPickerIconColor
        case .enhanced:
            color = theme?.mediaPickerIconActiveColor
        case .disabled:
            color = theme?.mediaPickerIconDisableColor
        }
        autoEnhanceButton.tintColor = color
    }
    
    // MARK: - Private
    
    @objc private func onRemoveButtonTap(_: UIButton) {
        onRemoveButtonTap?()
    }
    
    @objc private func onAutocorrectButtonTap(_: UIButton) {
        onAutocorrectButtonTap?()
    }
    
    @objc private func onCropButtonTap(_: UIButton) {
        onCropButtonTap?()
    }
    
    @objc private func onAutoEnhanceButtonTap(_: UIButton) {
        onAutoEnhanceButtonTap?()
    }
}
