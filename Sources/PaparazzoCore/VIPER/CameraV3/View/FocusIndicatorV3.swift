import UIKit

final class FocusIndicatorV3: CALayer {
    enum State {
        case small
        case large
    }
    
    struct Spec {
        static let size = CGSize(width: 70, height: 70)
        static let largeSize = CGSize(width: 90, height: 90)
    }
    private let shapeLayer = CAShapeLayer()
    private var beforeAnimationStrokeColor: UIColor?
    private var afterAnimationStrokeColor: UIColor?
    
    override init() {
        super.init()
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        addSublayer(shapeLayer)
        
        bounds = CGRect(x: 0, y: 0, width: Spec.size.width, height: Spec.size.height)
        shapeLayer.path = pathForState(.small).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTheme(_ theme: CameraV3UITheme) {
        beforeAnimationStrokeColor = theme.cameraV3BeforeAnimationStrokeColor
        afterAnimationStrokeColor = theme.cameraV3AfterAnimationStrokeColor
    }
    
    func show(in superlayer: CALayer, focusPoint: CGPoint) {
        position = focusPoint
        superlayer.addSublayer(self)
   
        weak var weakSelf = self
        animateAppearance {
            weakSelf?.animateScale {
                weakSelf?.animateHide()
            }
        }
    }
        
    func hide() {
        removeAllAnimations()
        removeFromSuperlayer()
    }
    
    private func animateAppearance(completion: @escaping () -> ()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        shapeLayer.strokeColor = beforeAnimationStrokeColor?.cgColor
        shapeLayer.add(appearanceAnimation(isAppear: true), forKey: nil)
        CATransaction.commit()
    }
    
    private func appearanceAnimation(isAppear: Bool) -> CABasicAnimation {
        basicAnimation(
            keyPath: #keyPath(CAShapeLayer.opacity),
            fromValue: isAppear ? 0 : 1,
            toValue: isAppear ? 1 : 0
        )
    }
    
    private func animateScale(completion: @escaping () -> ()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        shapeLayer.add(changePathAnimation(to: pathForState(.large).cgPath), forKey: nil)
        shapeLayer.add(changeCenterAnimation(), forKey: nil)
        shapeLayer.add(changeStrokeAnimation(), forKey: nil)
        
        CATransaction.commit()
    }
                       
    private func animateHide() {
        CATransaction.begin()
        shapeLayer.add(appearanceAnimation(isAppear: false), forKey: nil)
        CATransaction.commit()
    }
    
    private func changePathAnimation(to path: CGPath) -> CABasicAnimation {
        basicAnimation(
            keyPath: #keyPath(CAShapeLayer.path),
            fromValue: shapeLayer.path,
            toValue: path,
            beginTime: CACurrentMediaTime() + 0.5
        )
    }
    
    private func changeCenterAnimation() -> CABasicAnimation {
        basicAnimation(
            keyPath: #keyPath(CAShapeLayer.position),
            fromValue: shapeLayer.position,
            toValue: CGPoint(x: shapeLayer.position.x - 10, y: shapeLayer.position.y - 10),
            beginTime: CACurrentMediaTime() + 0.5
        )
    }
    
    private func changeStrokeAnimation() -> CABasicAnimation {
        basicAnimation(
            keyPath: #keyPath(CAShapeLayer.strokeColor),
            fromValue: shapeLayer.strokeColor,
            toValue: afterAnimationStrokeColor?.cgColor,
            beginTime: CACurrentMediaTime() + 0.5
        )
    }
    
    private func basicAnimation(
        keyPath: String,
        fromValue: Any?,
        toValue: Any?,
        beginTime: CFTimeInterval = .zero
    ) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = keyPath
        animation.beginTime = beginTime
        animation.duration = 0.3
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return animation
    }
    
    private func pathForState(_ state: State) -> UIBezierPath {
        var bounds = state == .small ? bounds : CGRect(x: 0, y: 0, width: Spec.largeSize.width, height: Spec.largeSize.height)
        bounds.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineWidth = 1
        
        // top left
        path.move(to: CGPoint(x: bounds.right - 24, y: bounds.top))
        path.addLine(to: CGPoint(x: bounds.right - 12, y: bounds.top))
        
        path.addArc(
            withCenter: CGPoint(x: bounds.right - 12, y: bounds.top + 12),
            radius: 12,
            startAngle: (3 * .pi) / 2,
            endAngle: 0,
            clockwise: true
        )
        
        path.move(to: CGPoint(x: bounds.right, y: bounds.top + 12))
        path.addLine(to: CGPoint(x: bounds.right, y: bounds.top + 24))
        
        // bottom left
        path.move(to: CGPoint(x: bounds.right, y: bounds.bottom - 24))
        path.addLine(to: CGPoint(x: bounds.right, y: bounds.bottom - 12))
        
        path.addArc(
            withCenter: CGPoint(x: bounds.right - 12, y: bounds.bottom - 12),
            radius: 12,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        path.move(to: CGPoint(x: bounds.right - 12, y: bounds.bottom))
        path.addLine(to: CGPoint(x: bounds.right - 24, y: bounds.bottom))

        // bottom right
        path.move(to: CGPoint(x: bounds.left + 24, y: bounds.bottom))
        path.addLine(to: CGPoint(x: bounds.left + 12, y: bounds.bottom))

        path.addArc(
            withCenter: CGPoint(x: bounds.left + 12, y: bounds.bottom - 12),
            radius: 12,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )

        path.move(to: CGPoint(x: bounds.left, y: bounds.bottom - 12))
        path.addLine(to: CGPoint(x: bounds.left, y: bounds.bottom - 24))
        
        // top right
        path.move(to: CGPoint(x: bounds.left, y: bounds.top + 24))
        path.addLine(to: CGPoint(x: bounds.left, y: bounds.top + 12))

        path.addArc(
            withCenter: CGPoint(x: bounds.left + 12, y: bounds.top + 12),
            radius: 12,
            startAngle: .pi,
            endAngle: (3 * .pi) / 2,
            clockwise: true
        )

        path.move(to: CGPoint(x: bounds.left + 12, y: bounds.top))
        path.addLine(to: CGPoint(x: bounds.left + 24, y: bounds.top))
        
        path.close()
        return path
    }
}
