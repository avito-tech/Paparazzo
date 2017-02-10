import CoreGraphics
import ImageSource

struct ImageCroppingParameters {
    
    let transform: CGAffineTransform
    let sourceSize: CGSize
    let sourceOrientation: ExifOrientation
    let outputWidth: CGFloat
    let cropSize: CGSize
    let imageViewSize: CGSize
    
    let contentOffsetCenter: CGPoint
    let turnAngle: CGFloat
    let tiltAngle: CGFloat
    let zoomScale: CGFloat
    let manuallyZoomed: Bool
}
