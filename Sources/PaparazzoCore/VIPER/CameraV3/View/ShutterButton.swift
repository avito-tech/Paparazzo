import UIKit

final class ShutterButton: UIView {
    enum State {
        case enabled
        case disabled
    }
    
    struct Spec {
        static let borderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = size.height / 2
        static let innerSize: CGSize = {
            let width = UIDevice.current.isIPhoneSE1OrLess ? 39 : 56
            return CGSize(width: width, height: width)
        }()
        static let innerCornerRadius: CGFloat = innerSize.height / 2
        static let size: CGSize = {
            let width = UIDevice.current.isIPhoneSE1OrLess ? 50 : 72
            return CGSize(width: width, height: width)
        }()
    }
    
    struct Theme {
        let scaleFactor: CGFloat
        let enabledColor: UIColor
        let disabledColor: UIColor
    }
    
    var onTap: (() -> ())?
    private lazy var innerButton = ScaleButton(frame: .init(origin: .zero, size: Spec.innerSize))
    private(set) var currentState: State = .enabled
    
    private var theme: Theme?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .init(origin: .zero, size: Spec.size))
        backgroundColor = .clear
        addSubview(innerButton)
        
        innerButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        innerButton.setAccessibilityId(.shutterButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderWidth = Spec.borderWidth
        layer.cornerRadius = Spec.cornerRadius
        innerButton.layer.cornerRadius = Spec.innerCornerRadius
        
        innerButton.centerY = bounds.centerY
        innerButton.centerX = bounds.centerX
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Spec.size
    }
    
    // MARK: - State
    
    func setState(_ state: State, animated: Bool) {
        currentState = state
        UIView.animate(withDuration: animated ? 0.2 : .zero) {
            self.updateAppearance()
        }
    }
    
    // MARK: - Theme
    
    func setTheme(_ theme: Theme) {
        self.theme = theme
        innerButton.setTheme(theme)
        updateAppearance()
    }
    
    // MARK: - Private
    
    private func updateAppearance() {
        guard let theme = theme else { return }
        innerButton.isEnabled = currentState == .enabled
        layer.borderColor = currentState == .enabled ? theme.enabledColor.cgColor : theme.disabledColor.cgColor
    }
    
    @objc private func tap() {
        onTap?()
    }
}

final class ScaleButton: UIButton {
    var theme: ShutterButton.Theme?
    
    override var isHighlighted: Bool {
        didSet {
            guard let theme = theme else { return }
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: theme.scaleFactor, y: theme.scaleFactor)
                : CGAffineTransform.identity
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            guard let theme = theme else { return }
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.isEnabled ? theme.enabledColor : theme.disabledColor
            }
        }
    }
    
    func setTheme(_ theme: ShutterButton.Theme) {
        self.theme = theme
        self.backgroundColor = isEnabled ? theme.enabledColor : theme.disabledColor
    }
}
