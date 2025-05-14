import UIKit

final class MedicalMaskOverlayView: UIView {
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isUserInteractionEnabled = false
        layer.addSublayer(shapeLayer)
        
        shapeLayer.strokeColor = Spec.lineColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = Spec.lineWidth
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawCorners()
    }

    private func drawCorners() {
        let path = UIBezierPath()
        let radius = Spec.cornerRadius
        let lineLenght = Spec.lineLength
        let width = bounds.width
        let height = bounds.height
        let insets = Spec.edgeInsets

        // Top-left
        path.move(to: CGPoint(x: insets.left, y: insets.top + lineLenght))
        path.addLine(to: CGPoint(x: insets.left, y: insets.top + radius))
        path.addArc(
            withCenter: CGPoint(x: insets.left + radius, y: insets.top + radius),
            radius: radius,
            startAngle: .pi,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: insets.left + lineLenght, y: insets.top))

        // Top-right
        path.move(to: CGPoint(x: width - insets.right, y: insets.top + lineLenght))
        path.addLine(to: CGPoint(x: width - insets.right, y: insets.top + radius))
        path.addArc(
            withCenter: CGPoint(x: width - insets.right - radius, y: insets.top + radius),
            radius: radius,
            startAngle: 0,
            endAngle: 3 * .pi / 2,
            clockwise: false
        )
        path.addLine(to: CGPoint(x: width - insets.right - lineLenght, y: insets.top))

        // Bottom-left
        path.move(to: CGPoint(x: insets.left, y: height - insets.bottom - lineLenght))
        path.addLine(to: CGPoint(x: insets.left, y: height - insets.bottom - radius))
        path.addArc(
            withCenter: CGPoint(x: insets.left + radius, y: height - insets.bottom - radius),
            radius: radius,
            startAngle: .pi,
            endAngle: .pi / 2,
            clockwise: false
        )
        path.addLine(to: CGPoint(x: insets.left + lineLenght, y: height - insets.bottom))

        // Bottom-right
        path.move(to: CGPoint(x: width - insets.right, y: height - insets.bottom - lineLenght))
        path.addLine(to: CGPoint(x: width - insets.right, y: height - insets.bottom - radius))
        path.addArc(
            withCenter: CGPoint(x: width - insets.right - radius, y: height - insets.bottom - radius),
            radius: radius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: width - insets.right - lineLenght, y: height - insets.bottom))

        shapeLayer.path = path.cgPath
    }

    private enum Spec {
        static let lineWidth: CGFloat = 3
        static let lineColor: UIColor = .white
        static let lineLength: CGFloat = 46
        static let cornerRadius: CGFloat = 12
        static let edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}
