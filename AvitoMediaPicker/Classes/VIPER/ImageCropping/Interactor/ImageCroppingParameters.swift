import CoreGraphics

struct ImageCroppingParameters {
    
    let transform: CGAffineTransform
    let sourceSize: CGSize
    let sourceOrientation: ExifOrientation
    let outputWidth: CGFloat
    let cropSize: CGSize
    let imageViewSize: CGSize
    
    let contentOffsetCenter: CGPoint
    let rotation: CGFloat
    let zoomScale: CGFloat
    let manuallyZoomed: Bool
}