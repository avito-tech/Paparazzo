import Foundation

extension Float {
    
    func degreesToRadians() -> Float {
        return self * Float(M_PI) / 180
    }
    
    func radiansToDegrees() -> Float {
        return self * 180 / Float(M_PI)
    }
}
