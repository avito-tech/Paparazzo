import CoreGraphics

extension CGImage {
    
    func imageFixedForOrientation(orientation: ExifOrientation) -> CGImage? {
        
        let ciContext = CIContext(options: nil)
        let ciImage = CIImage(CGImage: self).imageByApplyingOrientation(Int32(orientation.rawValue))
        
        return ciContext.createCGImage(ciImage, fromRect: ciImage.extent)
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
    
    var dimensionsSwapped: Bool {
        switch self {
        case .LeftMirrored, .Left, .RightMirrored, .Right:
            return true
        default:
            return false
        }
    }
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