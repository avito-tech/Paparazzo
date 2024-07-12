import CoreGraphics
import UIKit

extension CGAffineTransform {
    
    init(deviceOrientation: DeviceOrientation) {
        switch deviceOrientation {
        case .landscapeLeft:
            self = CGAffineTransform(rotationAngle: .pi / 2.0)
        case .landscapeRight:
            self = CGAffineTransform(rotationAngle: .pi / -2.0)
        case .portraitUpsideDown:
            self = CGAffineTransform(rotationAngle: .pi)
        default:
            self = .identity
        }
    }
    
    init(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .landscapeLeft:
            self = CGAffineTransform(rotationAngle: .pi / 2.0)
        case .landscapeRight:
            self = CGAffineTransform(rotationAngle: .pi / -2.0)
        case .portraitUpsideDown:
            self = CGAffineTransform(rotationAngle: .pi)
        default:
            self = .identity
        }
    }
}
