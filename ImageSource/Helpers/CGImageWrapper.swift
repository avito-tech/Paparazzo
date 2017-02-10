import CoreGraphics

public final class CGImageWrapper: InitializableWithCGImage {
    
    public let image: CGImage
    
    public init(cgImage image: CGImage) {
        self.image = image
    }
}
