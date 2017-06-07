import UIKit

final class AccessDeniedView: UIView, ThemeConfigurable {
    
    typealias ThemeType = AccessDeniedViewTheme
    
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let button = UIButton()
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    var buttonTitle: String? {
        get { return button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }
    
    var onButtonTap: (() -> ())?
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        button.backgroundColor = UIColor.RGB(red: 0, green: 170, blue: 255, alpha: 1)
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let frames = calculateFrames(forBounds: CGRect(origin: .zero, size: size))
        return CGSize(width: size.width, height: frames.buttonFrame.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frames = calculateFrames(forBounds: bounds)
        
        titleLabel.frame = frames.titleLabelFrame
        messageLabel.frame = frames.messageLabelFrame
        button.frame = frames.buttonFrame
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        titleLabel.font = theme.accessDeniedTitleFont
        messageLabel.font = theme.accessDeniedMessageFont
        button.titleLabel?.font = theme.accessDeniedButtonFont
    }
    
    // MARK: - Private
    
    private func calculateFrames(forBounds bounds: CGRect) -> (
        titleLabelFrame: CGRect,
        messageLabelFrame: CGRect,
        buttonFrame: CGRect)
    {
        let titleBottomMargin: CGFloat = 7
        let messageBottomMargin: CGFloat = 34
        let buttonHeight: CGFloat = 52
        
        let labelsWidth = bounds.size.width * 0.8
        let titleSize = titleLabel.sizeForWidth(labelsWidth)
        let messageSize = messageLabel.sizeForWidth(labelsWidth)
        
        let contentHeight = titleSize.height + titleBottomMargin + messageSize.height + messageBottomMargin + buttonHeight
        let contentTop = max(0, bounds.minY + (bounds.size.height - contentHeight) / 2)
        
        var titleLabelFrame = CGRect(
            origin: CGPoint(x: 0, y: contentTop),
            size: titleSize
        )
        titleLabelFrame.centerX = bounds.centerX
        
        var messageLabelFrame = CGRect(
            origin: .zero,
            size: messageSize
        )
        messageLabelFrame.centerX = bounds.centerX
        messageLabelFrame.top = titleLabelFrame.bottom + titleBottomMargin
        
        var buttonFrame = CGRect(origin: .zero, size: button.sizeThatFits(bounds.size))
        buttonFrame.centerX = bounds.centerX
        buttonFrame.top = messageLabelFrame.bottom + messageBottomMargin
        buttonFrame.size.height = buttonHeight
        
        return (
            titleLabelFrame: titleLabelFrame,
            messageLabelFrame: messageLabelFrame,
            buttonFrame: buttonFrame
        )
    }
    
    @objc private func onButtonTap(_: UIButton) {
        onButtonTap?()
    }
}
