import UIKit

final class GridView: UIView {
    
    let rowsCount = 3
    let columnsCount = 3
    
    private let shapeLayer = CAShapeLayer()
    private let isCenterSquare: Bool
    
    override init(frame: CGRect) {
        self.isCenterSquare = false
        super.init(frame: frame)
        self.configure()
    }
    
    init(isCenterSquare: Bool) {
        self.isCenterSquare = isCenterSquare
        super.init(frame: .zero)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        shapeLayer.path = path(forRect: shapeLayer.bounds).cgPath
        shapeLayer.shadowPath = shapeLayer.path
    }
    
    // MARK: - Private
    
    private func path(forRect rect: CGRect) -> UIBezierPath {
        
        let offset = isCenterSquare ? rect.size.height - rect.size.width : 0
        
        let rowHeight = (rect.size.height - offset) / CGFloat(rowsCount)
        let columnWidth = rect.size.width / CGFloat(columnsCount)
        
        let path = UIBezierPath()
        
        for row in 1 ..< rowsCount {
            
            let y = floor(CGFloat(row) * rowHeight) - 2 + offset / 2
            
            path.move(to: CGPoint(x: rect.left, y: y))
            path.addLine(to: CGPoint(x: rect.right, y: y))
        }
        
        for column in 1 ..< columnsCount {
            
            let x = floor(CGFloat(column) * columnWidth) + 2
            
            path.move(to: CGPoint(x: x, y: rect.top))
            path.addLine(to: CGPoint(x: x, y: rect.bottom))
        }
        
        return path
    }
    
    private func configure() {
        shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.25).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowRadius = 2
        
        layer.addSublayer(shapeLayer)
    }
}
