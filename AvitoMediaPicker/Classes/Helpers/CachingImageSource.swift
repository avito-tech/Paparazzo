import CoreGraphics

final class CachingImageSource: ImageSource {
    
    private let underlyingImageSource: ImageSource
    private let cache = NSCache()
    
    init(underlyingImageSource: ImageSource) {
        self.underlyingImageSource = underlyingImageSource
    }
    
    // MARK: - ImageSource
    
    func writeImageToUrl(url: NSURL, completion: Bool -> ()) {
        underlyingImageSource.writeImageToUrl(url, completion: completion)
    }
    
    func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        underlyingImageSource.fullResolutionImage(completion)
    }
    
    func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {
        
        let cacheKey = NSValue(CGSize: size)
        
        if let cachedCGImage = cache.objectForKey(cacheKey) {
            // Force unwrapping, потому что "Cast to Core Foundation types always succeeds in runtime"
            completion(T(CGImage: cachedCGImage as! CGImage))
        }
        
        underlyingImageSource.imageFittingSize(size, contentMode: contentMode) { [weak self] (imageWrapper: CGImageWrapper?) in
            
            let cgImage = imageWrapper?.image
            
            if let cgImage = cgImage {
                self?.cache.setObject(cgImage, forKey: cacheKey)
            }
            
            completion(cgImage.flatMap { T(CGImage: $0) })
        }
    }
}

private struct CGImageWrapper: InitializableWithCGImage {
    
    let image: CGImage
    
    init(CGImage image: CGImage) {
        self.image = image
    }
}