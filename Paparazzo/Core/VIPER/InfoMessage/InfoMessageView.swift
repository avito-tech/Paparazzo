import UIKit

struct InfoMessageViewData {
    let text: String
    let timeout: TimeInterval
}

final class InfoMessageView: UIView {
    
    private struct Layout {
        static let height: CGFloat = 22
        static let textInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        static let widthTextInsets = textInsets.left + textInsets.right
        static let heightTextInsets = textInsets.top + textInsets.bottom
    }
    
    private struct Spec {
        static let font = UIFont.systemFont(ofSize: 14)
        static let textColor = UIColor.black
        static let cornerRadius: CGFloat = 2
        static let backgroundColor = UIColor.white
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowOpacity: Float = 0.14
        static let shadowRadius: CGFloat = 2
    }
    
    private let textLabel = UILabel()
    private let contentView = UIView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        
        contentView.layer.cornerRadius = Spec.cornerRadius
        contentView.layer.masksToBounds = true
        
        textLabel.font = Spec.font
        textLabel.textColor = Spec.textColor
        contentView.addSubview(textLabel)
        
        contentView.backgroundColor = Spec.backgroundColor
        
        layer.masksToBounds = false
        layer.shadowOffset = Spec.shadowOffset
        layer.shadowRadius = Spec.shadowRadius
        layer.shadowOpacity = Spec.shadowOpacity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View data
    func setViewData(_ viewData: InfoMessageViewData) {
        textLabel.text = viewData.text
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = CGRect(
            x: Layout.textInsets.left,
            y: Layout.textInsets.top,
            width:  bounds.width - Layout.widthTextInsets,
            height: bounds.height - Layout.heightTextInsets
        )
        
        contentView.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let shrinkedSize = CGSize(
            width: size.width - Layout.widthTextInsets,
            height: Layout.height - Layout.heightTextInsets
        )
        
        let textSize = textLabel.sizeThatFits(shrinkedSize)
        
        return CGSize(
            width: textSize.width + Layout.widthTextInsets,
            height: Layout.height
        )
    }
}
