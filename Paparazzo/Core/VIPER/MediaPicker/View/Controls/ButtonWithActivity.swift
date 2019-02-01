import UIKit

final class ButtonWithActivity: UIButton {
    
    // MARK: - Subviews
    private let activity = UIActivityIndicatorView(style: .gray)
    
    // MARK: - State
    private var cachedTitle: String? = nil
    
    var style: MediaPickerContinueButtonStyle = .normal {
        didSet {
            switch style {
                
            case .normal:
                activity.stopAnimating()
                super.setTitle(cachedTitle, for: .normal)
                isUserInteractionEnabled = true
                
            case .spinner:
                activity.startAnimating()
                cachedTitle = title(for: .normal)
                super.setTitle(nil, for: .normal)
                isUserInteractionEnabled = false
            }
        }
    }
    
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        addSubview(activity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Title
    override func setTitle(_ title: String?, for state: UIControl.State) {
        switch style {
        case .normal:
            super.setTitle(title, for: state)
        case .spinner:
            if state == .normal {
                cachedTitle = title
            } else {
                super.setTitle(title, for: state)
            }
        }
        
    }
    
    // MARK: - Layout
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        switch style {
        case .normal:
            return super.sizeThatFits(size)
        case .spinner:
            return size.intersectionWidth(self.height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activity.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
