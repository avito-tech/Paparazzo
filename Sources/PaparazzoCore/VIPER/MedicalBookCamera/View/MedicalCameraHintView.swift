import UIKit

final class MedicalCameraHintView: UIView {
    
    private let label = UILabel()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        label.numberOfLines = 2
        label.textAlignment = .center
        label.setAccessibilityId(.cameraHint)
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = Spec.cornerRadius
        
        let size = label.sizeForWidth(bounds.width - (Spec.horizontalOffset * 2))

        label.frame = CGRect(
            centerX: bounds.centerX,
            centerY: bounds.centerY,
            width: size.width,
            height: size.height
        )
    }
    
    func setLabelText(_ text: String) {
        label.text = text
    }
    
    func setTheme(_ theme: MedicalBookCameraUITheme) {
        label.font = theme.medicalBookHintViewFont
        label.textColor = theme.medicalBookHintViewFontColor
        backgroundColor = theme.medicalBookHintViewBackground
    }
    
    private enum Spec {
        static let horizontalOffset: CGFloat = 20.0
        static let cornerRadius: CGFloat = 6.0
    }
}
