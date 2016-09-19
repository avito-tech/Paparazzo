import CoreGraphics

final class CGImageWrapper: InitializableWithCGImage {
    
    let image: CGImage
    
    init(cgImage image: CGImage) {
        self.image = image
    }
}
