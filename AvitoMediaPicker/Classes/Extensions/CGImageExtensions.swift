import CoreGraphics

extension CGImage {
    
    func imageFixedForOrientation(_ orientation: ExifOrientation) -> CGImage? {
        
        let ciContext = CIContext.fixed_context(options: [kCIContextUseSoftwareRenderer: false])
        let ciImage = CIImage(cgImage: self).applyingOrientation(Int32(orientation.rawValue))
        
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
    func scaled(_ scale: CGFloat) -> CGImage? {
        
        let width = Int(CGFloat(self.width) * scale)
        let height = Int(CGFloat(self.height) * scale)
        let bitsPerComponent = self.bitsPerComponent
        let bytesPerRow = self.bytesPerRow
        let bitmapInfo = self.bitmapInfo
        
        guard let colorSpace = self.colorSpace else { return nil }
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
        
        return context.makeImage()
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
