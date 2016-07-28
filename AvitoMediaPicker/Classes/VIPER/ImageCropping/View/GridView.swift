import UIKit

final class GridView: UIView {
    
    let rowsCount = 3
    let columnsCount = 3
    
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shapeLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        shapeLayer.lineWidth = 1
        shapeLayer.shadowColor = UIColor.blackColor().CGColor
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowRadius = 2
        
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        shapeLayer.path = pathForRect(shapeLayer.bounds).CGPath
        shapeLayer.shadowPath = shapeLayer.path
    }
    
    // MARK: - Private
    
    private func pathForRect(rect: CGRect) -> UIBezierPath {
        
        let rowHeight = rect.size.height / CGFloat(rowsCount)
        let columnWidth = rect.size.width / CGFloat(columnsCount)
        
        let path = UIBezierPath()
        
        for row in 1 ..< rowsCount {
            
            let y = floor(CGFloat(row) * rowHeight)
            
            path.moveToPoint(CGPoint(x: rect.left, y: y))
            path.addLineToPoint(CGPoint(x: rect.right, y: y))
        }
        
        for column in 1 ..< columnsCount {
            
            let x = floor(CGFloat(column) * columnWidth)
            
            path.moveToPoint(CGPoint(x: x, y: rect.top))
            path.addLineToPoint(CGPoint(x: x, y: rect.bottom))
        }
        
        return path
    }
}
