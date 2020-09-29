import UIKit

final class ExampleView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ExampleView
    
    func setItems(_ items: [ExampleViewItem]) {
        actions = items.map { $0.onTap }
        
        let buttons: [UIButton] = items.map {
            let button = UIButton()
            button.setTitle($0.title, for: .normal)
            button.addTarget(
                self,
                action: #selector(onButtonTap(_:)),
                for: .touchUpInside
            )
            return button
        }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.forEach { stackView.addArrangedSubview($0) }
    }
    
    private var actions = [(() -> ())?]()
    
    @objc func onButtonTap(_ sender: UIButton) {
        if let index  = stackView.arrangedSubviews.firstIndex(of: sender),
            actions.indices.contains(index)
        {
            actions[index]?()
        }
    }
}
