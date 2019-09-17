import UIKit

final class CameraViewfinderBorderView: UIView {
    
    private let topBorderLayer = CALayer()
    private let bottomBorderLayer = CALayer()
    private let leftBorderLayer = CALayer()
    private let rightBorderLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        alpha = 0.5
        
        topBorderLayer.backgroundColor = UIColor.white.cgColor
        bottomBorderLayer.backgroundColor = UIColor.white.cgColor
        leftBorderLayer.backgroundColor = UIColor.white.cgColor
        rightBorderLayer.backgroundColor = UIColor.white.cgColor
        
        layer.addSublayer(topBorderLayer)
        layer.addSublayer(bottomBorderLayer)
        layer.addSublayer(leftBorderLayer)
        layer.addSublayer(rightBorderLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBorderLayer.frame = CGRect(
            left: bounds.left + 6,
            right: bounds.right - 6,
            top: bounds.top + 16,
            height: 1
        )
        
        bottomBorderLayer.frame = CGRect(
            left: bounds.left + 6,
            right: bounds.right - 6,
            bottom: bounds.bottom - 16,
            height: 1
        )
        
        leftBorderLayer.frame = CGRect(
            x: bounds.left + 16,
            y: bounds.top + 6,
            width: 1,
            height: bounds.height - 6 * 2
        )
        
        rightBorderLayer.frame = CGRect(
            x: bounds.right - 16 - 1,
            y: bounds.top + 6,
            width: 1,
            height: bounds.height - 6 * 2
        )
    }
}
