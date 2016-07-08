import UIKit
import AvitoDesignKit

enum AspectRatioMode {
    case Portrait_3x4
    case Landscape_4x3
}

final class ImageCroppingView: UIView {
    
    // MARK: - Subviews
    
    private let controlsView = ImageCroppingControlsView()
    private let previewView = ZoomingImageView()   // TODO: надо заюзать что-то другое, например, CATiledLayer. Короче, поискать готовое решение.
    private let aspectRatioButton = UIButton()
    private let titleLabel = UILabel()
    
    private let topCurtain = UIView()
    private let bottomCurtain = UIView()
    
    // MARK: - Constants
    
    private let controlsMinHeight = CGFloat(165)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        aspectRatioButton.layer.borderWidth = 1
        aspectRatioButton.setTitleColor(.blackColor(), forState: .Normal)
        aspectRatioButton.addTarget(
            self,
            action: #selector(onAspectRatioButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        topCurtain.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
        bottomCurtain.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
        
        addSubview(previewView)
        addSubview(topCurtain)
        addSubview(bottomCurtain)
        addSubview(controlsView)
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
        
        controlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: max(controlsMinHeight, bounds.size.height * 0.25)   // оставляем вверху место под фотку 3:4
        )
        
        let previewViewHeight = bounds.size.width / previewAspectRatio()
        
        previewView.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top + max(0, (controlsView.top - bounds.top - previewViewHeight) / 2),
            height: previewViewHeight
        )
        
        topCurtain.layout(left: bounds.left, right: bounds.right, top: bounds.top, bottom: previewView.top)
        bottomCurtain.layout(left: bounds.left, right: bounds.right, top: previewView.bottom, bottom: controlsView.top)
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
    
    func setAspectRatioMode(mode: AspectRatioMode) {
        
        aspectRatioMode = mode
        
        aspectRatioButton.size = aspectRatioButtonSize()
        
        switch mode {
        
        case .Portrait_3x4:
            titleLabel.textColor = .whiteColor()
            aspectRatioButton.setTitleColor(.whiteColor(), forState: .Normal)
            aspectRatioButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        case .Landscape_4x3:
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
    
    func setCancelRotationButtonTitle(title: String) {
        controlsView.setCancelRotationButtonTitle(title)
    }
    
    func setCancelRotationButtonVisible(visible: Bool) {
        controlsView.setCancelRotationButtonVisible(visible)
    }
    
    // MARK: - Private
    
    private var aspectRatioMode: AspectRatioMode = .Portrait_3x4 {
        didSet {
            if aspectRatioMode != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    private func aspectRatioButtonSize() -> CGSize {
        switch aspectRatioMode {
        case .Portrait_3x4:
            return CGSize(width: 34, height: 42)
        case .Landscape_4x3:
            return CGSize(width: 42, height: 34)
        }
    }
    
    private func previewAspectRatio() -> CGFloat {
        switch aspectRatioMode {
        case .Portrait_3x4:
            return CGFloat(3.0 / 4.0)
        case .Landscape_4x3:
            return CGFloat(4.0 / 3.0)
        }
    }
    
    @objc private func onAspectRatioButtonTap(sender: UIButton) {
        onAspectRatioButtonTap?()
    }
}