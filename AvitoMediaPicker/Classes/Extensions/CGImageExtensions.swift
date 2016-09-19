import CoreGraphics

extension CGImage {
    
    func imageFixedForOrientation(_ orientation: ExifOrientation) -> CGImage? {
        
        let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        let ciImage = CIImage(cgImage: self).applyingOrientation(Int32(orientation.rawValue))
        
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
    func scaled(_ scale: CGFloat) -> CGImage? {
        
        let image = CIImage(cgImage: self)
        
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            assertionFailure("No CIFilter with name CILanczosScaleTransform found")
            return nil
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(1, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        
        return sharedGPUContext.createCGImage(outputImage, from: outputImage.extent)
    }
    
    func resized(toFit size: CGSize) -> CGImage? {
        
        let sourceWidth = CGFloat(width)
        let sourceHeight = CGFloat(height)
        
        if sourceWidth > 0 && sourceHeight > 0 {
            return scaled(min(size.width / sourceWidth, size.height / sourceHeight))
        } else {
            return nil
        }
    }
    
    func resized(toFill size: CGSize) -> CGImage? {
        
        let sourceWidth = CGFloat(width)
        let sourceHeight = CGFloat(height)
        
        if sourceWidth > 0 && sourceHeight > 0 {
            return scaled(max(size.width / sourceWidth, size.height / sourceHeight))
        } else {
            return nil
        }
    }
}

enum ExifOrientation: Int {
    
    case up = 1
    case upMirrored = 2
    case down = 3
    case downMirrored = 4
    case leftMirrored = 5
    case left = 6
    case rightMirrored = 7
    case right = 8
    
    var dimensionsSwapped: Bool {
        switch self {
        case .leftMirrored, .left, .rightMirrored, .right:
            return true
        default:
            return false
        }
    }
}

extension UIImageOrientation {
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

// Операция создания CIContext дорогостоящая, поэтому рекомендуется хранить его
private let sharedGPUContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
