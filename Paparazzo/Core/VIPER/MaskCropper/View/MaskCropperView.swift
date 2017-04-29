import ImageSource
import UIKit

final class MaskCropperView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MaskCropperUITheme
    
    private let overlayView: MaskCropperOverlayView
    private let controlsView = MaskCropperControlsView()
    private let previewView = CroppingPreviewView()
    private let closeButton = UIButton()
    private let confirmButton = UIButton()
    
    // MARK: - Constants
    
    private let aspectRatio = CGFloat(AspectRatio.portrait_3x4.widthToHeightRatio())
    private let closeButtonSize = CGSize(width: 38, height: 38)
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // MARK: - Init
    
    init(croppingOverlayProvider: CroppingOverlayProvider) {
        
        overlayView = MaskCropperOverlayView(
            croppingOverlayProvider: croppingOverlayProvider
        )
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        clipsToBounds = true
        
        previewView.setGridVisible(false)
        
        addSubview(previewView)
        addSubview(overlayView)
        addSubview(controlsView)
        addSubview(closeButton)
        addSubview(confirmButton)
        
        setupButtons()
        
        overlayView.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: MaskCropperUITheme) {
        controlsView.setTheme(theme)
        
        confirmButton.setTitleColor(theme.maskCropperConfirmButtonTitleColor, for: .normal)
        confirmButton.titleLabel?.font = theme.maskCropperConfirmButtonTitleFont
        
        closeButton.setImage(theme.maskCropperCloseButtonIcon, for: .normal)
        
        confirmButton.setTitleColor(
            theme.maskCropperConfirmButtonTitleColor,
            for: .normal
        )
        confirmButton.setTitleColor(
            theme.maskCropperConfirmButtonTitleHighlightedColor,
            for: .highlighted
        )
        
        let onePointSize = CGSize(width: 1, height: 1)
        for button in [confirmButton, closeButton] {
            button.setBackgroundImage(
                UIImage.imageWithColor(theme.maskCropperButtonsBackgroundNormalColor, imageSize: onePointSize),
                for: .normal
            )
            button.setBackgroundImage(
                UIImage.imageWithColor(theme.maskCropperButtonsBackgroundHighlightedColor, imageSize: onePointSize),
                for: .highlighted
            )
            button.setBackgroundImage(
                UIImage.imageWithColor(theme.maskCropperButtonsBackgroundDisabledColor, imageSize: onePointSize),
                for: .disabled
            )
        }
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        
        previewView.width = width
        previewView.height = height * aspectRatio
        
        overlayView.frame = previewView.frame
        
        controlsView.top = previewView.bottom
        controlsView.width = width
        controlsView.height = height - previewView.height
        
        closeButton.frame = CGRect(
            x: 8,
            y: 8,
            width: closeButton.width,
            height: closeButton.height
        )
        
        confirmButton.frame = CGRect(
            x: bounds.right - 8 - confirmButton.width,
            y: 8,
            width: confirmButton.width,
            height: confirmButton.height
        )
    }
    
    // MARK: - MaskCropperView
    
    var onCloseTap: (() -> ())?
    var onConfirmTap: ((_ previewImage: CGImage?) -> ())?
    
    var onDiscardTap: (() -> ())? {
        get { return controlsView.onDiscardTap }
        set { controlsView.onDiscardTap = newValue }
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        previewView.setCroppingParameters(parameters)
    }
    
    func setImage(_ imageSource: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ()) {
        previewView.setImage(imageSource, previewImage: previewImage, completion: completion)
    }
    
    func setCanvasSize(_ canvasSize: CGSize) {
        previewView.setCanvasSize(canvasSize)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        controlsView.setControlsEnabled(enabled)
    }
    
    func setConfirmButtonTitle(_ title: String) {
        confirmButton.setTitle(title, for: .normal)
        confirmButton.size = CGSize(width: confirmButton.sizeThatFits().width, height: continueButtonHeight)
    }
    
    // MARK: - Private
    
    private func setupButtons() {
        closeButton.layer.cornerRadius = closeButtonSize.height / 2
        closeButton.layer.masksToBounds = true
        closeButton.size = closeButtonSize
        closeButton.addTarget(
            self,
            action: #selector(onCloseTap(_:)),
            for: .touchUpInside
        )
        
        confirmButton.layer.cornerRadius = continueButtonHeight / 2
        confirmButton.layer.masksToBounds = true
        confirmButton.contentEdgeInsets = continueButtonContentInsets
        confirmButton.addTarget(
            self,
            action: #selector(onConfirmTap(_:)),
            for: .touchUpInside
        )
    }
    
    @objc private func onCloseTap(_: UIButton) {
        onCloseTap?()
    }
    
    @objc private func onConfirmTap(_: UIButton) {
        onConfirmTap?(previewView.cropPreviewImage())
    }
    
}
