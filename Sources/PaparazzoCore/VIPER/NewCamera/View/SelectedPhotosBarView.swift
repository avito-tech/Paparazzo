import ImageSource
import UIKit

final class SelectedPhotosBarView: UIView {
    
    let lastPhotoThumbnailView = UIImageView()
    private let penultimatePhotoThumbnailView = UIImageView()
    let label = UILabel()
    private let button = ButtonWithActivity(activityStyle: .white)
    private let placeholderLabel = UILabel()
    
    private let lastPhotoThumbnailSize = CGSize(width: 48, height: 36)
    private let penultimatePhotoThumbnailSize = CGSize(width: 43, height: 32)
    
    var onButtonTap: (() -> ())?
    var onLastPhotoThumbnailTap: (() -> ())?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        layer.cornerRadius = 10
        
        placeholderLabel.numberOfLines = 2
        placeholderLabel.textColor = UIColor(red: 0.646, green: 0.646, blue: 0.646, alpha: 1)
        
        lastPhotoThumbnailView.contentMode = .scaleAspectFill
        lastPhotoThumbnailView.clipsToBounds = true
        lastPhotoThumbnailView.layer.cornerRadius = 5
        lastPhotoThumbnailView.accessibilityIdentifier = "lastPhotoThumbnailView"
        
        penultimatePhotoThumbnailView.contentMode = .scaleAspectFill
        penultimatePhotoThumbnailView.clipsToBounds = true
        penultimatePhotoThumbnailView.alpha = 0.26
        penultimatePhotoThumbnailView.layer.cornerRadius = 5
        penultimatePhotoThumbnailView.accessibilityIdentifier = "penultimatePhotoThumbnailView"
        
        button.accessibilityIdentifier = AccessibilityId.doneButton.rawValue
        button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 11, right: 24)
        button.layer.backgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1).cgColor
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        
        lastPhotoThumbnailView.isUserInteractionEnabled = true
        lastPhotoThumbnailView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleLastPhotoThumbnailTap))
        )
        
        addSubview(penultimatePhotoThumbnailView)
        addSubview(lastPhotoThumbnailView)
        addSubview(label)
        addSubview(placeholderLabel)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SelectedPhotosBarView
    func setLastImage(_ imageSource: ImageSource?, resultHandler: ((ImageRequestResult<UIImage>) -> ())? = nil) {
        lastPhotoThumbnailView.setImage(
            fromSource: imageSource,
            size: lastPhotoThumbnailSize,
            resultHandler: resultHandler
        )
    }
    
    func setPenultimateImage(_ imageSource: ImageSource?, resultHandler: ((ImageRequestResult<UIImage>) -> ())? = nil) {
        penultimatePhotoThumbnailView.setImage(
            fromSource: imageSource,
            size: penultimatePhotoThumbnailSize,
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
        penultimatePhotoThumbnailView.isHidden = !isHidden
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
    
    // MARK: - UIView
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 72)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lastPhotoThumbnailView.layout(
            left: bounds.left + 15,
            top: bounds.top + 18,
            width: lastPhotoThumbnailSize.width,
            height: lastPhotoThumbnailSize.height
        )
        
        penultimatePhotoThumbnailView.layout(
            left: bounds.left + 19,
            top: lastPhotoThumbnailView.top + 9,
            width: penultimatePhotoThumbnailSize.width,
            height: penultimatePhotoThumbnailSize.height
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
            left: lastPhotoThumbnailView.right + 8,
            right: button.left - 16,
            top: bounds.top,
            bottom: bounds.bottom
        )
    }
    
    // MARK: - Private - Layout
    private func layOutButton() {
        let buttonSize = button.sizeThatFits()
        
        button.frame = CGRect(
            x: bounds.right - 16 - buttonSize.width,
            y: floor(bounds.centerY - buttonSize.height / 2),
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    // MARK: - Private - Event handlers
    @objc private func handleButtonTap() {
        onButtonTap?()
    }
    
    @objc private func handleLastPhotoThumbnailTap() {
        onLastPhotoThumbnailTap?()
    }
}
