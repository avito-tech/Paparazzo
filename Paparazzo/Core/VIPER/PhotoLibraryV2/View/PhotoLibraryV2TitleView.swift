import UIKit

final class PhotoLibraryV2TitleView: UIView {
    
    var contentInsets: UIEdgeInsets = .zero
    
    // MARK: - Subviews
    private let label = UILabel()
    private let iconView = UIImageView()
    
    // MARK: - Specs
    private let labelToIconSpacing: CGFloat = 8
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(label)
        addSubview(iconView)
        
        iconView.tintColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PhotoLibraryTitleView
    func setTitle(_ title: String) {
        label.text = title
        setNeedsLayout()
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
    
    func rotateIconUp() {
        iconView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
    }
    
    func rotateIconDown() {
        // Set angle 0.001 instead of 0 for icon to rotate counterclockwise. Otherwise it will always rotate clockwise.
        iconView.transform = CGAffineTransform(rotationAngle: 0.001)
    }
    
    // MARK: - UIView
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 49 + paparazzoSafeAreaInsets.top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = iconView.image?.size ?? .zero
        let topInset = paparazzoSafeAreaInsets.top / 3
        
        label.resizeToFitWidth(bounds.width - 2 * (labelToIconSpacing + iconSize.width) - contentInsets.left - contentInsets.right)
        label.left = (bounds.width - (label.width + labelToIconSpacing + iconSize.width)) / 2
        label.centerY = bounds.centerY + topInset
        
        // Don't use `frame` here, otherwise the rotation animation will be broken
        iconView.bounds = CGRect(origin: .zero, size: iconSize)
        iconView.center = CGPoint(
            x: ceil(label.right + labelToIconSpacing) + iconSize.width / 2,
            y: ceil(bounds.centerY + topInset + 2 - iconSize.height / 2) + iconSize.height / 2
        )
    }
}
