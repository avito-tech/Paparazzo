import ImageSource
import UIKit

final class SelectedPhotosV3BarView: UIView {
    
    // MARK: UI elements
    
    private lazy var shadowLayer: CALayer = {
        let layer = CALayer()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.masksToBounds = false
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }()
    
    private lazy var lastPhotoOverlay = CALayer()
    
    private lazy var lastPhotoThumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.accessibilityIdentifier = AccessibilityId.lastPhotoThumbnailView.rawValue
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private(set) lazy var label = UILabel()
    
    private lazy var confirmButton: ButtonWithActivity = {
        let button = ButtonWithActivity(activityStyle: .white)
        button.accessibilityIdentifier = AccessibilityId.doneButton.rawValue
        button.titleEdgeInsets = Spec.confirmButtonInsets
        return button
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: Spec
    
    private enum Spec {
        static let confirmButtonInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        static let lastPhotoThumbnailSize = CGSize(width: 40, height: 40)
        static let contentInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        static let placeholderInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 7)
    }
    
    // MARK: Handler
    
    var onButtonTap: (() -> ())?
    var onLastPhotoThumbnailTap: (() -> ())?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        confirmButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        lastPhotoThumbnailView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleLastPhotoThumbnailTap))
        )
         
        layer.addSublayer(shadowLayer)
        lastPhotoThumbnailView.layer.addSublayer(lastPhotoOverlay)
        addSubview(lastPhotoThumbnailView)
        addSubview(label)
        addSubview(placeholderLabel)
        addSubview(confirmButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 72)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.frame = bounds
        shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        
        lastPhotoThumbnailView.layout(
            left: bounds.left + Spec.contentInsets.left,
            top: bounds.top + Spec.contentInsets.top,
            width: Spec.lastPhotoThumbnailSize.width,
            height: Spec.lastPhotoThumbnailSize.height
        )
        
        lastPhotoOverlay.frame = lastPhotoThumbnailView.bounds
        
        layOutButton()
        
        let placeholderSize = placeholderLabel.sizeForWidth(confirmButton.left - bounds.left - Spec.placeholderInsets.width)
        placeholderLabel.frame = CGRect(
            x: bounds.left + Spec.placeholderInsets.left,
            y: floor(bounds.top + (bounds.height - placeholderSize.height) / 2),
            width: placeholderSize.width,
            height: placeholderSize.height
        )
        
        label.layout(
            left: lastPhotoThumbnailView.right + 15,
            right: confirmButton.left - 12,
            top: bounds.top + Spec.contentInsets.top,
            bottom: bounds.bottom - Spec.contentInsets.bottom
        )
    }
    
    // MARK: SelectedPhotosV3BarView
    
    func setLastImage(_ imageSource: ImageSource?, resultHandler: ((ImageRequestResult<UIImage>) -> ())? = nil) {
        lastPhotoThumbnailView.setImage(
            fromSource: imageSource,
            size: Spec.lastPhotoThumbnailSize,
            resultHandler: resultHandler
        )
    }
    
    func setTheme(_ theme: NewCameraUITheme) {
        backgroundColor = theme.newCameraSelectedPhotosBarBackgroundColor
        shadowLayer.cornerRadius = theme.newCameraSelectedPhotosBarCornerRadius
        lastPhotoOverlay.backgroundColor = theme.newCameraSelectedPhotosBarPhotoOverlayColor.cgColor
        lastPhotoThumbnailView.layer.cornerRadius = theme.newCameraSelectedPhotosBarPhotoCornerRadius
        label.textColor = theme.newCameraPhotosCountColor
        label.font = theme.newCameraPhotosCountFont
        placeholderLabel.font = theme.newCameraPhotosCountPlaceholderFont
        placeholderLabel.textColor = theme.newCameraPhotosCountPlaceholderColor
        confirmButton.titleLabel?.font = theme.newCameraDoneButtonFont
        confirmButton.setTitleColor(theme.newCameraSelectedPhotosBarButtonTitleColorNormal, for: .normal)
        confirmButton.backgroundColor = theme.newCameraSelectedPhotosBarButtonBackgroundColor
        confirmButton.layer.cornerRadius = theme.newCameraSelectedPhotosBarButtonCornerRadius
    }
    
    func setDoneButtonTitle(_ title: String) {
        confirmButton.setTitle(title, for: .normal)
        setNeedsLayout()
    }
    
    func setPlaceholderText(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.07
        
        placeholderLabel.attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        
        setNeedsLayout()
    }
    
    func setPlaceholderHidden(_ isHidden: Bool) {
        placeholderLabel.isHidden = isHidden
        
        label.isHidden = !isHidden
        lastPhotoThumbnailView.isHidden = !isHidden
    }
    
    func setHidden(_ isHidden: Bool, animated: Bool) {
        guard self.isHidden != isHidden else { return }
        
        if animated && isHidden {
            transform = .identity
            
            UIView.animate(
                withDuration: 0.15,
                animations: {
                    self.alpha = 0
                    self.transform = CGAffineTransform(translationX: 0, y: 5)
                },
                completion: { _ in
                    self.isHidden = true
                    self.transform = .identity
                }
            )
        } else if animated && !isHidden {
            self.isHidden = false
            
            alpha = 0
            transform = CGAffineTransform(translationX: 0, y: 5)
            
            UIView.animate(
                withDuration: 0.15,
                animations: {
                    self.alpha = 1
                    self.transform = .identity
                }
            )
        } else {
            self.isHidden = isHidden
        }
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        guard confirmButton.style != style else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.confirmButton.style = style
                self.layOutButton()
            }
        )
    }
}

// MARK: - Private methods

private extension SelectedPhotosV3BarView {
    private func layOutButton() {
        let buttonSize = confirmButton.sizeThatFits()
        
        confirmButton.frame = CGRect(
            x: bounds.right - 16 - buttonSize.width,
            y: floor(bounds.centerY - buttonSize.height / 2),
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    @objc private func handleButtonTap() {
        onButtonTap?()
    }
    
    @objc private func handleLastPhotoThumbnailTap() {
        onLastPhotoThumbnailTap?()
    }
}
