import UIKit

final class PhotoLibraryTitleView: UIView {
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PhotoLibraryTitleView
    func setTitle(_ title: String) {
        label.text = title
        setNeedsLayout()
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
        iconView.transform = .identity
    }
    
    // MARK: - UIView
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 49)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = iconView.image?.size ?? .zero
        
        label.resizeToFitWidth(bounds.width - labelToIconSpacing - iconSize.width)
        label.left = (bounds.width - (label.width + labelToIconSpacing + iconSize.width)) / 2
        label.centerY = bounds.centerY
        
        // Don't use `frame` here, otherwise the rotation animation will be broken
        iconView.bounds = CGRect(origin: .zero, size: iconSize)
        iconView.center = CGPoint(
            x: label.right + labelToIconSpacing + iconSize.width / 2,
            y: bounds.centerY + 2
        )
    }
}
