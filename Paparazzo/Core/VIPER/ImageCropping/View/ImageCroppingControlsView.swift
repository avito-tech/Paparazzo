import UIKit

final class ImageCroppingControlsView: UIView, ThemeConfigurable {
    
    typealias ThemeType = ImageCroppingUITheme
    
    // MARK: - Subviews
    
    private let rotationSliderView = RotationSliderView()
    private let rotationButton = UIButton()
    private let rotationCancelButton = RightIconButton()
    private let gridButton = UIButton()
    private let discardButton = UIButton()
    private let confirmButton = UIButton()
    
    // MARK: - Constants
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        rotationCancelButton.backgroundColor = .RGB(red: 25, green: 25, blue: 25, alpha: 1)
        rotationCancelButton.setTitleColor(.white, for: .normal)
        rotationCancelButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)
        rotationCancelButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        rotationCancelButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        rotationCancelButton.addTarget(
            self,
            action: #selector(onRotationCancelButtonTap(_:)),
            for: .touchUpInside
        )
        
        rotationButton.addTarget(
            self,
            action: #selector(onRotationButtonTap(_:)),
            for: .touchUpInside
        )
        
        gridButton.addTarget(
            self,
            action: #selector(onGridButtonTap(_:)),
            for: .touchUpInside
        )
        
        discardButton.addTarget(
            self,
            action: #selector(onDiscardButtonTap(_:)),
            for: .touchUpInside
        )
        
        confirmButton.addTarget(
            self,
            action: #selector(onConfirmButtonTap(_:)),
            for: .touchUpInside
        )
        
        addSubview(rotationSliderView)
        addSubview(rotationButton)
        addSubview(gridButton)
        addSubview(rotationCancelButton)
        addSubview(discardButton)
        addSubview(confirmButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rotationSliderView.layout(
            left: bounds.left + 50,
            right: bounds.right - 50,
            top: 19,
            height: 44
        )
        
        rotationButton.size = CGSize.minimumTapAreaSize
        rotationButton.center = CGPoint(x: 31, y: rotationSliderView.centerY)
        
        gridButton.size = CGSize.minimumTapAreaSize
        gridButton.center = CGPoint(x: bounds.right - 31, y: rotationSliderView.centerY)
        
        rotationCancelButton.centerX = bounds.centerX
        rotationCancelButton.top = rotationSliderView.bottom + 11
        
        discardButton.size = CGSize.minimumTapAreaSize
        discardButton.center = CGPoint(x: bounds.left + bounds.size.width * 0.25, y: bounds.bottom - 42)
        
        confirmButton.size = CGSize.minimumTapAreaSize
        confirmButton.center = CGPoint(x: bounds.right - bounds.size.width * 0.25, y: discardButton.centerY)
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        rotationButton.setImage(theme.rotationIcon, for: .normal)
        gridButton.setImage(theme.gridIcon, for: .normal)
        gridButton.setImage(theme.gridSelectedIcon, for: .selected)
        discardButton.setImage(theme.cropperDiscardIcon, for: .normal)
        confirmButton.setImage(theme.cropperConfirmIcon, for: .normal)
        
        rotationCancelButton.backgroundColor = theme.cancelRotationBackgroundColor
        rotationCancelButton.titleLabel?.textColor = theme.cancelRotationTitleColor
        rotationCancelButton.titleLabel?.font = theme.cancelRotationTitleFont
        rotationCancelButton.setImage(theme.cancelRotationButtonIcon, for: .normal)
    }
    
    // MARK: - ImageCroppingControlsView
    
    var onDiscardButtonTap: (() -> ())?
    var onConfirmButtonTap: (() -> ())?
    var onRotationCancelButtonTap: (() -> ())?
    var onRotateButtonTap: (() -> ())?
    var onGridButtonTap: (() -> ())?
    
    var onRotationAngleChange: ((Float) -> ())? {
        get { return rotationSliderView.onSliderValueChange }
        set { rotationSliderView.onSliderValueChange = newValue }
    }
    
    func setMinimumRotation(degrees: Float) {
        rotationSliderView.setMiminumValue(degrees)
    }
    
    func setMaximumRotation(degrees: Float) {
        rotationSliderView.setMaximumValue(degrees)
    }
    
    func setRotationSliderValue(_ value: Float) {
        rotationSliderView.setValue(value)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        rotationButton.isEnabled = enabled
        gridButton.isEnabled = enabled
        rotationSliderView.isUserInteractionEnabled = enabled
        rotationCancelButton.isEnabled = enabled
    }
    
    func setCancelRotationButtonTitle(_ title: String) {
        rotationCancelButton.setTitle(title, for: .normal)
        rotationCancelButton.sizeToFit()
        rotationCancelButton.layer.cornerRadius = rotationCancelButton.size.height / 2
    }
    
    func setCancelRotationButtonVisible(_ visible: Bool) {
        rotationCancelButton.isHidden = !visible
    }
    
    func setGridButtonSelected(_ selected: Bool) {
        gridButton.isSelected = selected
    }
    
    // MARK: - Private
    
    @objc private func onDiscardButtonTap(_: UIButton) {
        onDiscardButtonTap?()
    }
    
    @objc private func onConfirmButtonTap(_: UIButton) {
        onConfirmButtonTap?()
    }
    
    @objc private func onRotationSliderValueChange(_ sender: UISlider) {
        onRotationAngleChange?(sender.value)
    }
    
    @objc private func onRotationCancelButtonTap(_: UIButton) {
        onRotationCancelButtonTap?()
    }
    
    @objc private func onRotationButtonTap(_: UIButton) {
        onRotateButtonTap?()
    }
    
    @objc private func onGridButtonTap(_: UIButton) {
        onGridButtonTap?()
    }
}
