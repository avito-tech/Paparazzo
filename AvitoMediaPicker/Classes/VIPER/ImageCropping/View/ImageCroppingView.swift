import UIKit
import AvitoDesignKit

enum AspectRatioMode {
    case Portrait
    case Landscape
}

final class ImageCroppingView: UIView {
    
    // MARK: - Subviews
    
    private let controlsView = ImageCroppingControlsView()
    private let previewView = ZoomingImageView()   // TODO: надо заюзать что-то другое, например, CATiledLayer. Короче, поискать готовое решение.
    private let stencilView = CropStencilView()
    private let aspectRatioButton = UIButton()
    private let titleLabel = UILabel()
    
    // MARK: - Constants
    
    private let photoAspectRatio = CGFloat(3.0 / 4.0)
    private let controlsHeight = CGFloat(165)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        stencilView.userInteractionEnabled = false
        
        aspectRatioButton.layer.borderWidth = 1
        aspectRatioButton.setTitleColor(.blackColor(), forState: .Normal)
        aspectRatioButton.addTarget(
            self,
            action: #selector(onAspectRatioButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        addSubview(previewView)
        addSubview(controlsView)
        addSubview(stencilView)
        addSubview(titleLabel)
        addSubview(aspectRatioButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        aspectRatioButton.top = 14
        aspectRatioButton.right = bounds.right - 12
        
        titleLabel.resizeToFitWidth(bounds.size.width - 2 * (bounds.right - aspectRatioButton.left))
        titleLabel.centerX = bounds.centerX
        titleLabel.top = 13
        
        previewView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.width / photoAspectRatio
        )
        
        stencilView.frame = previewView.frame
        
        controlsView.frame = CGRect(
            x: 0,
            y: bounds.bottom - 165,
            width: bounds.size.width,
            height: 165
        )
    }
    
    // MARK: - ImageCroppingView
    
    var onDiscardButtonTap: (() -> ())? {
        get { return controlsView.onDiscardButtonTap }
        set { controlsView.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: (() -> ())? {
        get { return controlsView.onConfirmButtonTap }
        set { controlsView.onConfirmButtonTap = newValue }
    }
    
    var onRotationAngleChange: (Float -> ())? {
        get { return controlsView.onRotationAngleChange }
        set { controlsView.onRotationAngleChange = newValue }
    }
    
    var onRotateButtonTap: (() -> ())? {
        get { return controlsView.onRotateButtonTap }
        set { controlsView.onRotateButtonTap = newValue }
    }
    
    var onRotationCancelButtonTap: (() -> ())? {
        get { return controlsView.onRotationCancelButtonTap }
        set { controlsView.onRotationCancelButtonTap = newValue }
    }
    
    var onGridButtonTap: (() -> ())? {
        get { return controlsView.onGridButtonTap }
        set { controlsView.onGridButtonTap = newValue }
    }
    
    var onAspectRatioButtonTap: (() -> ())?
    
    func setImage(image: ImageSource) {
        image.fullResolutionImage { [weak self] (image: UIImage?) in
            self?.previewView.image = image
        }
    }
    
    func setImageRotation(angle: CGFloat) {
        previewView.setImageRotation(angle)
    }
    
    func setRotationSliderValue(value: Float) {
        controlsView.setRotationSliderValue(value)
    }
    
    func setTheme(theme: ImageCroppingUITheme) {
        controlsView.setTheme(theme)
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setAspectRatioButtonMode(mode: AspectRatioMode) {
        
        aspectRatioButton.size = aspectRatioButtonSizeForMode(mode)
        
        switch mode {
        
        case .Portrait:
            titleLabel.textColor = .whiteColor()
            aspectRatioButton.setTitleColor(.whiteColor(), forState: .Normal)
            aspectRatioButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        case .Landscape:
            titleLabel.textColor = .blackColor()
            aspectRatioButton.setTitleColor(.blackColor(), forState: .Normal)
            aspectRatioButton.layer.borderColor = UIColor.blackColor().CGColor
        }
    }
    
    func setAspectRatioButtonTitle(title: String) {
        aspectRatioButton.setTitle(title, forState: .Normal)
    }
    
    func setMinimumRotation(degrees: Float) {
        controlsView.setMinimumRotation(degrees)
    }
    
    func setMaximumRotation(degrees: Float) {
        controlsView.setMaximumRotation(degrees)
    }
    
    func showStencilForAspectRatioMode(mode: AspectRatioMode) {
        stencilView.aspectRatio = stencilAspectRatioForMode(mode)
        stencilView.hidden = false
    }
    
    func hideStencil() {
        stencilView.hidden = true
    }
    
    func setCancelRotationButtonTitle(title: String) {
        controlsView.setCancelRotationButtonTitle(title)
    }
    
    func setCancelRotationButtonVisible(visible: Bool) {
        controlsView.setCancelRotationButtonVisible(visible)
    }
    
    // MARK: - Private
    
    private func aspectRatioButtonSizeForMode(mode: AspectRatioMode) -> CGSize {
        switch mode {
        case .Portrait:
            return CGSize(width: 34, height: 42)
        case .Landscape:
            return CGSize(width: 42, height: 34)
        }
    }
    
    private func stencilAspectRatioForMode(mode: AspectRatioMode) -> CGFloat {
        switch mode {
        case .Portrait:
            return CGFloat(3.0 / 4.0)
        case .Landscape:
            return CGFloat(4.0 / 3.0)
        }
    }
    
    @objc private func onAspectRatioButtonTap(sender: UIButton) {
        onAspectRatioButtonTap?()
    }
}