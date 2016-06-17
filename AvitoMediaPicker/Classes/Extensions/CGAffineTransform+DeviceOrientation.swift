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
}