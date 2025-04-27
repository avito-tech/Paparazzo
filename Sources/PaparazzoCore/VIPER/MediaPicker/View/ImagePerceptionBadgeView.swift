import Foundation
import UIKit

public struct ImagePerceptionBadgeViewData {
    let imageID: String?
    let title: String?
    let color: UIColor?
    let onTap: ((_ imageID: String) -> ())?
    
    public init(
        imageID: String? = nil,
        title: String? = nil,
        color: UIColor? = nil,
        onTap: ((String) -> ())? = nil
    ) {
        self.imageID = imageID
        self.title = title
        self.color = color
        self.onTap = onTap
    }
    
    public static let empty = Self.init(imageID: nil, title: nil, color: nil, onTap: nil)
}

final class ImagePerceptionBadgeView: UIView {
    
    // MARK: - Private Properties
    
    private var theme: MediaPickerRootModuleUITheme? {
        didSet {
            guard let theme else { return }
            titleLabel.textColor = theme.imagePerceptionBadgeTextColor
            titleLabel.font = theme.imagePerceptionBadgeTextFont
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    private var onTap: ((String) -> ())?
    
    private var viewData: ImagePerceptionBadgeViewData = .empty {
        didSet {
            guard
                let imageId = viewData.imageID,
                !imageId.isEmpty,
                let title = viewData.title,
                !title.isEmpty,
                let color = viewData.color,
                let onTap = viewData.onTap
            else {
                isHidden = true
                return
            }
            isHidden = false
            titleLabel.text = title
            backgroundColor = color
            self.onTap = onTap
        }
    }
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        addSubview(titleLabel)
        isHidden = true
        
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap)
            )
        )
        
        accessibilityIdentifier = "ImagePerceptionBadgeView"
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.layout(
            left: bounds.left + Spec.textInsets.left,
            right: bounds.right - Spec.textInsets.right,
            top: bounds.top + Spec.textInsets.top,
            bottom: bounds.bottom - Spec.textInsets.bottom
        )
        
        layer.cornerRadius = Spec.cornerRadius
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(
            width: titleLabel.sizeThatFits().width + Spec.textInsets.left + Spec.textInsets.right,
            height: Spec.badgeHeight
        )
    }
    
    // MARK: - Internal Methods
    
    func setViewData(
        _ viewData: ImagePerceptionBadgeViewData
    ) {
        self.viewData = viewData
    }
    
    func setTheme(
        _ theme: MediaPickerRootModuleUITheme
    ) {
        self.theme = theme
    }
    
    // MARK: - Private Methods
    
    @objc
    private func handleTap() {
        onTap?(viewData.imageID ?? "")
    }
    
    // MARK: - Spec
    
    private enum Spec {
        static let cornerRadius: CGFloat = 6
        static let badgeHeight: CGFloat = 20
        static let textInsets = UIEdgeInsets(top: 2, left: 6, bottom: 3, right: 6)
    }
    
}
