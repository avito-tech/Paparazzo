final class CircleCroppingOverlayProvider: CroppingOverlayProvider {
    
    func calculateRectToCrop(in bounds: CGRect) -> CGRect {
        let diameter = bounds.width - 16
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
        return UIBezierPath(ovalIn: rect).cgPath
    }
    
}
