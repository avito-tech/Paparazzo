import UIKit

final class ImageCroppingControlsView: UIView {
    
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
        
        backgroundColor = .whiteColor()
        
        rotationCancelButton.backgroundColor = .RGB(red: 25, green: 25, blue: 25, alpha: 1)
        rotationCancelButton.setTitleColor(.whiteColor(), forState: .Normal)
        rotationCancelButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)
        rotationCancelButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        rotationCancelButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        rotationCancelButton.addTarget(
            self,
            action: #selector(onRotationCancelButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        rotationButton.addTarget(
            self,
            action: #selector(onRotationButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        gridButton.addTarget(
            self,
            action: #selector(onGridButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        discardButton.addTarget(
            self,
            action: #selector(onDiscardButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        confirmButton.addTarget(
            self,
            action: #selector(onConfirmButtonTap(_:)),
            forControlEvents: .TouchUpInside
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
        discardButton.center = CGPoint(x: bounds.left + 100, y: bounds.bottom - 42)
        
        confirmButton.size = CGSize.minimumTapAreaSize
        confirmButton.center = CGPoint(x: bounds.right - 100, y: discardButton.centerY)
    }
    
    // MARK: - ImageCroppingControlsView
    
    var onDiscardButtonTap: (() -> ())?
    var onConfirmButtonTap: (() -> ())?
    var onRotationCancelButtonTap: (() -> ())?
    var onRotateButtonTap: (() -> ())?
    var onGridButtonTap: (() -> ())?
    
    var onRotationAngleChange: (Float -> ())? {
        get { return rotationSliderView.onSliderValueChange }
        set { rotationSliderView.onSliderValueChange = newValue }
    }
    
    func setTheme(theme: ImageCroppingUITheme) {
        rotationButton.setImage(theme.rotationIcon, forState: .Normal)
        gridButton.setImage(theme.gridIcon, forState: .Normal)
        discardButton.setImage(theme.cropperDiscardIcon, forState: .Normal)
        confirmButton.setImage(theme.cropperConfirmIcon, forState: .Normal)
        
        rotationCancelButton.backgroundColor = theme.cancelRotationBackgroundColor
        rotationCancelButton.titleLabel?.textColor = theme.cancelRotationTitleColor
        rotationCancelButton.titleLabel?.font = theme.cancelRotationTitleFont
        rotationCancelButton.setImage(theme.cancelRotationButtonIcon, forState: .Normal)
    }
    
    func setMinimumRotation(degrees: Float) {
        rotationSliderView.setMiminumValue(degrees)
    }
    
    func setMaximumRotation(degrees: Float) {
        rotationSliderView.setMaximumValue(degrees)
    }
    
    func setRotationSliderValue(value: Float) {
        rotationSliderView.setValue(value)
    }
    
    func setControlsEnabled(enabled: Bool) {
        rotationButton.enabled = enabled
        gridButton.enabled = enabled
        rotationSliderView.userInteractionEnabled = enabled
        rotationCancelButton.enabled = enabled
    }
    
    func setCancelRotationButtonTitle(title: String) {
        rotationCancelButton.setTitle(title, forState: .Normal)
        rotationCancelButton.sizeToFit()
        rotationCancelButton.layer.cornerRadius = rotationCancelButton.size.height / 2
    }
    
    func setCancelRotationButtonVisible(visible: Bool) {
        rotationCancelButton.hidden = !visible
    }
    
    // MARK: - Private
    
    @objc private func onDiscardButtonTap(sender: UIButton) {
        onDiscardButtonTap?()
    }
    
    @objc private func onConfirmButtonTap(sender: UIButton) {
        onConfirmButtonTap?()
    }
    
    @objc private func onRotationSliderValueChange(sender: UISlider) {
        onRotationAngleChange?(sender.value)
    }
    
    @objc private func onRotationCancelButtonTap(sender: UIButton) {
        onRotationCancelButtonTap?()
    }
    
    @objc private func onRotationButtonTap(sender: UIButton) {
        onRotateButtonTap?()
    }
    
    @objc private func onGridButtonTap(sender: UIButton) {
        onGridButtonTap?()
    }
}