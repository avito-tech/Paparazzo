import Foundation

extension Float {
    
    func degreesToRadians() -> Float {
        return self * .pi / 180
    }
    
    func radiansToDegrees() -> Float {
        return self * 180 / .pi
    }
}
