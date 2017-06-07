import CoreGraphics
import UIKit

public extension CGImage {
    
    func imageFixedForOrientation(_ orientation: ExifOrientation) -> CGImage? {
        
        let ciContext = CIContext.fixed_context(options: [kCIContextUseSoftwareRenderer: false])
        let ciImage = CIImage(cgImage: self).applyingOrientation(Int32(orientation.rawValue))
        
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
    func scaled(_ scale: CGFloat) -> CGImage? {
        
        let outputWidth = CGFloat(width) * scale
        let outputHeight = CGFloat(height) * scale
        
        guard let colorSpace = colorSpace,
            let context = CGContext(
                data: nil,
                width: Int(outputWidth),
                height: Int(outputHeight),
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue
            ) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: outputWidth, height: outputHeight)))
        
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

public enum ExifOrientation: Int {
    
    case up = 1
    case upMirrored = 2
    case down = 3
    case downMirrored = 4
    case leftMirrored = 5
    case left = 6
    case rightMirrored = 7
    case right = 8
    
    public var dimensionsSwapped: Bool {
        switch self {
        case .leftMirrored, .left, .rightMirrored, .right:
            return true
        default:
            return false
        }
    }
}
