import UIKit

final class FocusIndicator: CALayer {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    private let shapeLayer = CAShapeLayer()
    
    override init() {
        super.init()
        
        let radius = CGFloat(30)
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )

        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
                
        addSublayer(shapeLayer)
        
        bounds = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_  color: UIColor) {
        shapeLayer.strokeColor = color.cgColor
    }
    
    func animate(in superlayer: CALayer, focusPoint: CGPoint) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        position = focusPoint
        
        superlayer.addSublayer(self)
        CATransaction.setCompletionBlock {
            self.removeFromSuperlayer()
        }
        
        self.add(FocusIndicatorScaleAnimation(), forKey: nil)
        self.add(FocusIndicatorOpacityAnimation(), forKey: nil)
        opacity = 0
        
        CATransaction.commit()
    }
    
    func hide() {
        removeAllAnimations()
        removeFromSuperlayer()
    }
}

final class FocusIndicatorScaleAnimation: CABasicAnimation {
    override init() {
        super.init()
        keyPath = "transform.scale"
        fromValue = 0.8
        toValue = 1.0
        duration = 0.3
        autoreverses = true
        isRemovedOnCompletion = false
        timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FocusIndicatorOpacityAnimation: CABasicAnimation {
    override init() {
        super.init()
        keyPath = "opacity"
        fromValue = 0
        toValue = 1.0
        duration = 0.3
        autoreverses = true
        isRemovedOnCompletion = false
        timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
