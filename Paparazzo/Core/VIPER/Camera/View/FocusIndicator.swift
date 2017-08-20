import UIKit

final class FocusIndicator: CALayer, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    private let shapeLayer = CAShapeLayer()
    
    override init() {
        super.init()
        
        let radius = CGFloat(30)
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat(M_PI * 2),
            clockwise: true
        )

        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
        
        let shapeContainterLayer = CALayer()
        
        addSublayer(shapeLayer)
        
        bounds = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        shapeLayer.strokeColor = theme.focusIndicatorColor.cgColor
    }
    
    func animate(in superlayer: CALayer, focusPoint: CGPoint) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        position = focusPoint
        
        superlayer.addSublayer(self)
        CATransaction.setCompletionBlock {
            self.removeFromSuperlayer()
        }
        
        self.add(FocusIndicatorAnimation(), forKey: nil)
        
        CATransaction.commit()
    }
}

final class FocusIndicatorAnimation: CABasicAnimation {
    override init() {
        super.init()
        keyPath = "transform.scale"
        fromValue = 0.8
        toValue = 1.0
        duration = 0.3
        autoreverses = true
        isRemovedOnCompletion = false
        timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

