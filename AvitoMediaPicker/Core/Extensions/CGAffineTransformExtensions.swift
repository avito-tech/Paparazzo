import CoreGraphics

extension CGAffineTransform {
    
    init(deviceOrientation: DeviceOrientation) {
        switch deviceOrientation {
        case .landscapeLeft:
            self = CGAffineTransform(rotationAngle: CGFloat(M_PI) / 2.0)
        case .landscapeRight:
            self = CGAffineTransform(rotationAngle: CGFloat(M_PI) / -2.0)
        case .portraitUpsideDown:
            self = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        default:
            self = .identity
        }
    }
    
    init(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .landscapeLeft:
            self = CGAffineTransform(rotationAngle: CGFloat(M_PI) / 2.0)
        case .landscapeRight:
            self = CGAffineTransform(rotationAngle: CGFloat(M_PI) / -2.0)
        case .portraitUpsideDown:
            self = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        default:
            self = .identity
        }
    }
}
