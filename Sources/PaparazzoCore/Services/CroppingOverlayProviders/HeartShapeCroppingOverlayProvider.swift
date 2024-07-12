import UIKit

private extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

final class HeartShapeCroppingOverlayProvider: CroppingOverlayProvider {
    
    // MARK :- CroppingOverlayProvider
    
    func calculateRectToCrop(in bounds: CGRect) -> CGRect {
        return CGRect(
            origin: CGPoint(
                x: bounds.center.x - bounds.width / 2,
                y: bounds.center.y - bounds.height / 2
            ),
            size: CGSize(
                width: bounds.width,
                height: bounds.width
            )
        )
    }
    
    func croppingPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        
        //Calculate Radius of Arcs using Pythagoras
        let sideOne = rect.width * 0.4
        let sideTwo = rect.height * 0.3
        let arcRadius = sqrt(sideOne * sideOne + sideTwo * sideTwo) / 2
        
        //Left Hand Curve
        path.addArc(
            withCenter: CGPoint(x: rect.width * 0.3, y: rect.height * 0.35),
            radius: arcRadius,
            startAngle: 135.degreesToRadians,
            endAngle: 315.degreesToRadians,
            clockwise: true
        )
        
        //Top Centre Dip
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height * 0.2))
        
        //Right Hand Curve
        path.addArc(
            withCenter: CGPoint(x: rect.width * 0.7, y: rect.height * 0.35),
            radius: arcRadius,
            startAngle: 225.degreesToRadians,
            endAngle: 45.degreesToRadians,
            clockwise: true
        )
        
        //Right Bottom Line
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95))
        
        //Left Bottom Line
        path.close()
        
        let transform = CGAffineTransform(translationX: 0, y: rect.centerY / 2 - 22.5)
        path.apply(transform)
        
        return path.cgPath
    }
    
}
