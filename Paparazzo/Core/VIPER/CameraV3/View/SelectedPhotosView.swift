import UIKit
import ImageSource

struct SelectedPhotosViewData {
    let text: String
    let topItem: ImageSource
    let behindItem: ImageSource?
}

final class SelectedPhotosView: UIView {
    struct Spec {
        static let size = CGSize(width: 56, height: 60)
        static let topItemSize = CGSize(width: 56, height: 56)
        static let behindItemSize = CGSize(width: 48, height: 48)
        static let cornerRadius: CGFloat = 12
        static let overlaySize = CGSize(width: size.width * 1.3, height: size.width * 1.3)
    }
    
    var onTap: (() -> ())?
    
    private var viewData: SelectedPhotosViewData?
    private var overlay = UIView()
    private var label = UILabel()
    private var topImage = UIImageView()
    private var behindImage = UIImageView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        overlay.backgroundColor = .black
        topImage.layer.masksToBounds = true
        behindImage.layer.masksToBounds = true
        label.textAlignment = .center
        overlay.alpha = 0.4
        topImage.layer.borderColor = UIColor.black.cgColor
        behindImage.layer.borderColor = UIColor.black.cgColor
        topImage.layer.borderWidth = 1
        behindImage.layer.borderWidth = 1
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topImage.layer.cornerRadius = Spec.cornerRadius
        behindImage.layer.cornerRadius = Spec.cornerRadius
        
        overlay.center = bounds.center
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Spec.size
    }
    
    func setTheme(_ theme: CameraV3UITheme) {
        label.textColor = theme.cameraV3SelectedPhotosFontColor
        label.font = theme.cameraV3SelectedPhotosFont
    }
    
    func setViewData(_ viewData: SelectedPhotosViewData?, animated: Bool) {
        guard let viewData = viewData else {
            clearContent()
            return
        }
        
        addSubview(behindImage)
        addSubview(topImage)
        addSubview(overlay)
        addSubview(label)
    
        label.text = viewData.text
        topImage.setImage(fromSource: viewData.topItem, size: Spec.topItemSize)

        overlay.frame = CGRect(
            centerX: bounds.centerX,
            centerY: bounds.centerY,
            width: Spec.overlaySize.width,
            height: Spec.overlaySize.height
        )
        
        topImage.frame = CGRect(
            x: 0,
            y: 0,
            width: Spec.topItemSize.width,
            height: Spec.topItemSize.height
        )
        
        behindImage.frame = CGRect(
            x: 4,
            y: 12,
            width: Spec.behindItemSize.width,
            height: Spec.behindItemSize.height
        )
        topImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        
        if let behind = viewData.behindItem {
            behindImage.setImage(fromSource: behind, size: Spec.behindItemSize)
            behindImage.alpha = 0.4
        }
        
        label.frame = CGRect(
            centerX: topImage.centerX,
            centerY: topImage.centerY,
            width: Spec.topItemSize.width,
            height: Spec.topItemSize.height
        )
        
        UIView.animate(
            withDuration: animated ? 0.6 : 0,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut]
        ) {
            self.topImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    private func clearContent() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
