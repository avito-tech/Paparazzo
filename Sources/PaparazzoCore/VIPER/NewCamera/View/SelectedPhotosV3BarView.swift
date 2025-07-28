import ImageSource
import UIKit

final class SelectedPhotosV3BarView: UIView {
    
    // MARK: UI elements
    
    private lazy var lastPhotoThumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.accessibilityIdentifier = "lastPhotoThumbnailView"
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private(set) lazy var label = UILabel()
    
    private lazy var button: ButtonWithActivity = {
        let button = ButtonWithActivity(activityStyle: .white)
        button.accessibilityIdentifier = AccessibilityId.doneButton.rawValue
        button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        button.layer.backgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1).cgColor
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor(red: 0.646, green: 0.646, blue: 0.646, alpha: 1)
        return label
    }()
    
    // MARK: Spec
    
    private let lastPhotoThumbnailSize = CGSize(width: 40, height: 40)
    private let contentInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    
    // MARK: Handler
    
    var onButtonTap: (() -> ())?
    var onLastPhotoThumbnailTap: (() -> ())?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        lastPhotoThumbnailView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleLastPhotoThumbnailTap))
        )
        
        addSubview(lastPhotoThumbnailView)
        addSubview(label)
        addSubview(placeholderLabel)
        addSubview(button)
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
        
        lastPhotoThumbnailView.layout(
            left: bounds.left + contentInsets.left,
            top: bounds.top + contentInsets.top,
            width: lastPhotoThumbnailSize.width,
            height: lastPhotoThumbnailSize.height
        )
        
        layOutButton()
        
        let placeholderInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 7)
        let placeholderSize = placeholderLabel.sizeForWidth(button.left - bounds.left - placeholderInsets.width)
        
        placeholderLabel.frame = CGRect(
            x: bounds.left + placeholderInsets.left,
            y: floor(bounds.top + (bounds.height - placeholderSize.height) / 2),
            width: placeholderSize.width,
            height: placeholderSize.height
        )
        
        label.layout(
            left: lastPhotoThumbnailView.right + 15,
            right: button.left - 12,
            top: bounds.top + contentInsets.top,
            bottom: bounds.bottom - contentInsets.bottom
        )
    }
    
    // MARK: SelectedPhotosV3BarView
    
    func setLastImage(_ imageSource: ImageSource?, resultHandler: ((ImageRequestResult<UIImage>) -> ())? = nil) {
        lastPhotoThumbnailView.setImage(
            fromSource: imageSource,
            size: lastPhotoThumbnailSize,
            resultHandler: resultHandler
        )
    }
    
    func setTheme(_ theme: NewCameraUITheme) {
        backgroundColor = theme.newCameraSelectedPhotosBarBackgroundColor
        label.textColor = theme.newCameraPhotosCountColor
        label.font = theme.newCameraPhotosCountFont
        placeholderLabel.font = theme.newCameraPhotosCountPlaceholderFont
        placeholderLabel.textColor = theme.newCameraPhotosCountPlaceholderColor
        button.titleLabel?.font = theme.newCameraDoneButtonFont
        button.setTitleColor(theme.newCameraSelectedPhotosBarButtonTitleColorNormal, for: .normal)
        button.backgroundColor = theme.newCameraSelectedPhotosBarButtonBackgroundColor
    }
    
    func setDoneButtonTitle(_ title: String) {
        button.setTitle(title, for: .normal)
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
        guard button.style != style else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.button.style = style
                self.layOutButton()
            }
        )
    }
}

// MARK: - Private methods

private extension SelectedPhotosV3BarView {
    private func layOutButton() {
        let buttonSize = button.sizeThatFits()
        
        button.frame = CGRect(
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
