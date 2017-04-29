import UIKit

final class RectangleCroppingOverlayProvider: CroppingOverlayProvider {
    
    private let cornerRadius: CGFloat
    private let margin: CGFloat
    
    init(cornerRadius: CGFloat, margin: CGFloat) {
        self.cornerRadius = cornerRadius
        self.margin = margin
    }
    
    // MARK :- CroppingOverlayProvider
    
    func calculateRectToCrop(in bounds: CGRect) -> CGRect {
        let diameter = bounds.width - margin
        return CGRect(
            origin: CGPoint(
                x: bounds.center.x - diameter / 2,
                y: bounds.center.y - diameter / 2
            ),
            size: CGSize(
                width: diameter,
                height: diameter
            )
        )
    }
    
    func croppingPath(in rect: CGRect) -> CGPath {
        return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
    }
    
}
