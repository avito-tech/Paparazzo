import UIKit

final class AccessDeniedView: UIView {
    
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
        get { return button.titleForState(.Normal) }
        set { button.setTitle(newValue, forState: .Normal) }
    }
    
    var onButtonTap: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        
        button.backgroundColor = UIColor.RGB(red: 0, green: 170, blue: 255, alpha: 1)
        button.layer.cornerRadius = 4
        button.setTitleColor(.whiteColor(), forState: .Normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.addTarget(self, action: #selector(onButtonTap(_:)), forControlEvents: .TouchUpInside)
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
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
    
    // MARK: - Private
    
    private func calculateFrames(forBounds bounds: CGRect) -> (
        titleLabelFrame: CGRect,
        messageLabelFrame: CGRect,
        buttonFrame: CGRect)
    {
        var titleLabelFrame = CGRect(
            origin: .zero,
            size: titleLabel.sizeForWidth(bounds.size.width)
        )
        titleLabelFrame.centerX = bounds.centerX
        
        var messageLabelFrame = CGRect(
            origin: .zero,
            size: messageLabel.sizeForWidth(bounds.size.width)
        )
        messageLabelFrame.centerX = bounds.centerX
        messageLabelFrame.top = titleLabelFrame.bottom + 7
        
        let buttonSideMargin = CGFloat(60)
        
        var buttonFrame = CGRect(origin: .zero, size: button.sizeThatFits(bounds.size))
        buttonFrame.centerX = bounds.centerX
        buttonFrame.top = messageLabelFrame.bottom + 34
        buttonFrame.height = 52
        
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
