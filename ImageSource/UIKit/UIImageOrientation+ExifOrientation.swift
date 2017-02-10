public extension UIImageOrientation {
    var exifOrientation: ExifOrientation {
        switch self {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .rightMirrored
        case .left:
            return .right
        case .rightMirrored:
            return .leftMirrored
        case .right:
            return .left
        }
    }
}
