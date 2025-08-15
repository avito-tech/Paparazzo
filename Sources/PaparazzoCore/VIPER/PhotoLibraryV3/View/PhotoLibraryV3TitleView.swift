import UIKit

final class PhotoLibraryV3TitleView: UIView {
    
    // MARK: Properties
    
    var contentInsets: UIEdgeInsets = .zero
    
    // MARK: UI elements
    
    private let label = UILabel()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "iconView"
        return imageView
    }()
    
    // MARK: Specs
    
    private enum Spec {
        static let labelToIconSpacing: CGFloat = 4
        static let baseHeight: CGFloat = 52
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(label)
        addSubview(iconView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: PhotoLibraryV3TitleView
    
    func setTitle(_ title: String) {
        label.text = title
        setNeedsLayout()
    }
    
    func setTitleColor(_ color: UIColor) {
        label.textColor = color
    }
    
    func setTitleVisible(_ visible: Bool) {
        label.isHidden = !visible
        iconView.isHidden = !visible
    }
    
    func setLabelFont(_ font: UIFont) {
        label.font = font
        setNeedsLayout()
    }
    
    func setIcon(_ icon: UIImage?) {
        iconView.image = icon
        setNeedsLayout()
    }
    
    func setIconColor(_ color: UIColor) {
        iconView.tintColor = color
    }
    
    func rotateIconUp() {
        iconView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
    }
    
    func rotateIconDown() {
        // Set angle 0.001 instead of 0 for icon to rotate counterclockwise. Otherwise it will always rotate clockwise.
        iconView.transform = CGAffineTransform(rotationAngle: 0.001)
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: Spec.baseHeight + paparazzoSafeAreaInsets.top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = iconView.image?.size ?? .zero
        let topInset = paparazzoSafeAreaInsets.top / 3
        
        label.resizeToFitWidth(bounds.width - 2 * (Spec.labelToIconSpacing + iconSize.width) - contentInsets.left - contentInsets.right)
        label.left = (bounds.width - (label.width + Spec.labelToIconSpacing + iconSize.width)) / 2
        label.centerY = bounds.centerY + topInset
        
        // Don't use `frame` here, otherwise the rotation animation will be broken
        iconView.bounds = CGRect(origin: .zero, size: iconSize)
        iconView.center = CGPoint(
            x: ceil(label.right + Spec.labelToIconSpacing) + iconSize.width / 2,
            y: ceil(bounds.centerY + topInset + 2 - iconSize.height / 2) + iconSize.height / 2
        )
    }
}
