import CoreGraphics

extension CGImage {
    
    func imageFixedForOrientation(orientation: ExifOrientation) -> CGImage? {
        
        let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        let ciImage = CIImage(CGImage: self).imageByApplyingOrientation(Int32(orientation.rawValue))
        
        return ciContext.createCGImage(ciImage, fromRect: ciImage.extent)
    }
    
    func scaled(scale: CGFloat) -> CGImage? {
        
        let image = CIImage(CGImage: self)
        
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            assertionFailure("No CIFilter with name CILanczosScaleTransform found")
            return nil
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(1, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = filter.valueForKey(kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        
        return sharedGPUContext.createCGImage(outputImage, fromRect: outputImage.extent)
    }
    
    func resized(toFit size: CGSize) -> CGImage? {
        
        let sourceWidth = CGFloat(CGImageGetWidth(self))
        let sourceHeight = CGFloat(CGImageGetHeight(self))
        
        if sourceWidth > 0 && sourceHeight > 0 {
            return scaled(min(size.width / sourceWidth, size.height / sourceHeight))
        } else {
            return nil
        }
    }
    
    func resized(toFill size: CGSize) -> CGImage? {
        
        let sourceWidth = CGFloat(CGImageGetWidth(self))
        let sourceHeight = CGFloat(CGImageGetHeight(self))
        
        if sourceWidth > 0 && sourceHeight > 0 {
            return scaled(max(size.width / sourceWidth, size.height / sourceHeight))
        } else {
            return nil
        }
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

// Операция создания CIContext дорогостоящая, поэтому рекомендуется хранить его
private let sharedGPUContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])