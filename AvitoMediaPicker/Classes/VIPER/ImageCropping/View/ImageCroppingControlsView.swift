import UIKit

final class ImageCroppingControlsView: UIView {
    
    // MARK: - Subviews
    
    private let rotationSlider = UISlider()
    private let rotationButton = UIButton()
    private let rotationCancelButton = ImageRotationCancelButton()
    private let gridButton = UIButton()
    private let discardButton = UIButton()
    private let confirmButton = UIButton()
    
    // MARK: - Constants
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .whiteColor()
        
        rotationSlider.addTarget(
            self,
            action: #selector(onRotationSliderValueChange(_:)),
            forControlEvents: .ValueChanged
        )
        
        rotationCancelButton.backgroundColor = .blackColor()
        rotationCancelButton.setTitleColor(.whiteColor(), forState: .Normal)
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
        
        addSubview(rotationSlider)
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
        
        // TOO: сделать адекватный layout
        
        rotationSlider.frame = CGRect(
            x: bounds.left + 58,
            y: bounds.top + 18,
            width: bounds.size.width - 2 * 58,
            height: 44
        )
        
        rotationButton.sizeToFit()
        rotationButton.center = CGPoint(x: 31, y: rotationSlider.centerY)
        
        gridButton.sizeToFit()
        gridButton.center = CGPoint(x: bounds.right - 31, y: rotationSlider.centerY)
        
        discardButton.sizeToFit()
        discardButton.center = CGPoint(x: bounds.left + 100, y: bounds.bottom - 42)
        
        confirmButton.sizeToFit()
        confirmButton.center = CGPoint(x: bounds.right - 100, y: discardButton.centerY)
    }
    
    // MARK: - ImageCroppingControlsView
    
    var onDiscardButtonTap: (() -> ())?
    var onConfirmButtonTap: (() -> ())?
    var onRotationAngleChange: (Float -> ())?
    var onRotationCancelButtonTap: (() -> ())?
    var onRotateButtonTap: (() -> ())?
    var onGridButtonTap: (() -> ())?
    
    func setTheme(theme: ImageCroppingUITheme) {
        rotationButton.setImage(theme.rotationIcon, forState: .Normal)
        rotationCancelButton.setImage(theme.cropCancelButtonIcon, forState: .Normal)
        gridButton.setImage(theme.gridIcon, forState: .Normal)
        discardButton.setImage(theme.cropperDiscardIcon, forState: .Normal)
        confirmButton.setImage(theme.cropperConfirmIcon, forState: .Normal)
    }
    
    func setMinimumRotation(degrees: Float) {
        rotationSlider.minimumValue = degrees
    }
    
    func setMaximumRotation(degrees: Float) {
        rotationSlider.maximumValue = degrees
    }
    
    func setCancelRotationButtonTitle(title: String) {
        rotationCancelButton.setTitle(title, forState: .Normal)
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