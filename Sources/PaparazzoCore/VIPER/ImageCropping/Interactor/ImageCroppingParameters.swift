import CoreGraphics
import ImageSource

struct ImageCroppingParameters: Equatable {
    
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
    
    static func ==(parameters1: ImageCroppingParameters, parameters2: ImageCroppingParameters) -> Bool {
        return parameters1.transform == parameters2.transform &&
               parameters1.sourceSize == parameters2.sourceSize &&
               parameters1.sourceOrientation == parameters2.sourceOrientation &&
               parameters1.outputWidth == parameters2.outputWidth &&
               parameters1.cropSize == parameters2.cropSize &&
               parameters1.imageViewSize == parameters2.imageViewSize &&
               parameters1.contentOffsetCenter == parameters2.contentOffsetCenter &&
               parameters1.turnAngle == parameters2.turnAngle &&
               parameters1.tiltAngle == parameters2.tiltAngle &&
               parameters1.zoomScale == parameters2.zoomScale &&
               parameters1.manuallyZoomed == parameters2.manuallyZoomed
    }
}
