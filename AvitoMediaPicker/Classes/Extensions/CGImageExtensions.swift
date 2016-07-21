import CoreGraphics

extension CGImage {
    
    func imageFixedForOrientation(orientation: ExifOrientation) -> CGImage? {
        
        let originalSize = CGSize(width: CGImageGetWidth(self), height: CGImageGetHeight(self))
        
        var size = originalSize
        var rotation = CGFloat(0)
        
        switch orientation {
        case .Left:
            size = CGSize(width: size.height, height: size.width)
            rotation = CGFloat(-M_PI_2)
        case .Right:
            size = CGSize(width: size.height, height: size.width)
            rotation = CGFloat(M_PI_2)
        case .Down:
            rotation = CGFloat(M_PI)
        default:
            return self
        }
        
        let contextRect = CGRect(origin: .zero, size: originalSize)
        
        let context = CGBitmapContextCreate(
            nil,
            Int(size.width),
            Int(size.height),
            CGImageGetBitsPerComponent(self),
            0,
            CGImageGetColorSpace(self),
            CGImageGetBitmapInfo(self).rawValue
        )
        
        CGContextTranslateCTM(context, size.width / 2, size.height / 2)
        CGContextRotateCTM(context, rotation)
        CGContextTranslateCTM(context, -size.height / 2, -size.width / 2)
        
        CGContextDrawImage(context, contextRect, self)
        
        return CGBitmapContextCreateImage(context)
    }
}

enum ExifOrientation: Int {
    case Up = 1
    case UpMirrored = 2
    case Down = 3
    case DownMirrored = 4
    case LeftMirrored = 5
    case Left = 6
    case RightMirrored = 7
    case Right = 8
}

extension UIImageOrientation {
    var exifOrientation: ExifOrientation {
        switch self {
        case .Up:
            return .Up
        case .UpMirrored:
            return .UpMirrored
        case .Down:
            return .Down
        case .DownMirrored:
            return .DownMirrored
        case .LeftMirrored:
            return .RightMirrored
        case .Left:
            return .Right
        case .RightMirrored:
            return .LeftMirrored
        case .Right:
            return .Left
        }
    }
}