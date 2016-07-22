import CoreGraphics

public final class CroppedImageSource: ImageSource {
    
    public let originalImage: ImageSource
    
    init(originalImage: ImageSource) {
        self.originalImage = originalImage
    }
    
    // MARK: - ImageSource
    
    public func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        // TODO
    }
    
    public func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {
        // TODO
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        // TODO
    }
    
    public func writeImageToUrl(url: NSURL, completion: Bool -> ()) {
        // TODO
    }
}