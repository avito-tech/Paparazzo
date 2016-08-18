import CoreGraphics

extension CGAffineTransform {
    
    init(deviceOrientation: DeviceOrientation) {
        switch deviceOrientation {
        case .LandscapeLeft:
            self = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2.0)
        case .LandscapeRight:
            self = CGAffineTransformMakeRotation(CGFloat(M_PI) / -2.0)
        case .PortraitUpsideDown:
            self = CGAffineTransformMakeRotation(CGFloat(M_PI))
        default:
            self = CGAffineTransformIdentity
        }
    }
    
    func translate(dx dx: CGFloat, dy: CGFloat) -> CGAffineTransform {
        return CGAffineTransformTranslate(self, dx, dy)
    }
    
    func rotate(by angle: CGFloat) -> CGAffineTransform {
        return CGAffineTransformRotate(self, angle)
    }
    
    func scale(x x: CGFloat, y: CGFloat) -> CGAffineTransform {
        return CGAffineTransformScale(self, x, y)
    }
    
    func append(transform: CGAffineTransform) -> CGAffineTransform {
        return CGAffineTransformConcat(self, transform)
    }
}