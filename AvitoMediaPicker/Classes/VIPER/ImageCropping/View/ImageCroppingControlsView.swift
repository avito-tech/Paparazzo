import UIKit

final class ImageCroppingControlsView: UIView {
    
    // MARK: - Subviews
    
    private let rotationSlider = UISlider()
    private let rotationButton = UIButton()
    private let gridButton = UIButton()
    private let discardButton = UIButton()
    private let confirmButton = UIButton()
    
    // MARK: - Constants
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .whiteColor()
        
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
    
    func setTheme(theme: ImageCroppingUITheme) {
        rotationButton.setImage(theme.rotationIcon, forState: .Normal)
        gridButton.setImage(theme.gridIcon, forState: .Normal)
        discardButton.setImage(theme.cropperDiscardIcon, forState: .Normal)
        confirmButton.setImage(theme.cropperConfirmIcon, forState: .Normal)
    }
    
    // MARK: - Private
    
    @objc private func onDiscardButtonTap(sender: UIButton) {
        onDiscardButtonTap?()
    }
    
    @objc private func onConfirmButtonTap(sender: UIButton) {
        onConfirmButtonTap?()
    }
}