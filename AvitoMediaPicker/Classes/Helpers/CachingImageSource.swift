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
        
        if let cachedImageWrapper = cache.objectForKey(cacheKey) as? CGImageWrapper {
            completion(T(CGImage: cachedImageWrapper.image))
        }
        
        underlyingImageSource.imageFittingSize(size, contentMode: contentMode) { [weak self] (imageWrapper: CGImageWrapper?) in
            
            let cgImage = imageWrapper?.image
            
            if let imageWrapper = imageWrapper {
                self?.cache.setObject(imageWrapper, forKey: cacheKey)
            }
            
            completion(cgImage.flatMap { T(CGImage: $0) })
        }
    }
}

private final class CGImageWrapper: InitializableWithCGImage {
    
    let image: CGImage
    
    init(CGImage image: CGImage) {
        self.image = image
    }
}