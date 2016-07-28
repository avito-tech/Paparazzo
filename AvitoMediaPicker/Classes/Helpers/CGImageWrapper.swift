import CoreGraphics
import AvitoDesignKit

final class CGImageWrapper: InitializableWithCGImage {
    
    let image: CGImage
    
    init(CGImage image: CGImage) {
        self.image = image
    }
}