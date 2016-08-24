import CoreGraphics

// Пока что использовать с осторожностью, надо тестить
final class CachingImageSource: ImageSource {
    
    private let underlyingImageSource: ImageSource
    private let cache = NSCache()
    
    public init(underlyingImageSource: ImageSource) {
        // Не даем создавать вложенные CachingImageSource
        if let cachingImageSource = underlyingImageSource as? CachingImageSource {
            self.underlyingImageSource = cachingImageSource.underlyingImageSource
        } else {
            self.underlyingImageSource = underlyingImageSource
        }
    }
    
    // MARK: - ImageSource
    
    public func fullResolutionImageData(completion: NSData? -> ()) {
        underlyingImageSource.fullResolutionImageData(completion)
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        underlyingImageSource.imageSize(completion)
    }
    
    public func requestImage<T : InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: ImageRequestResult<T> -> ())
        -> ImageRequestId
    {
        let cacheKey = ImageRequestCacheKey(size: options.size)
        
        if let cachedImageWrapper = cache.objectForKey(cacheKey) as? CGImageWrapper {
            
            dispatch_to_main_queue {
                resultHandler(ImageRequestResult(
                    image: T(CGImage: cachedImageWrapper.image),
                    degraded: false,
                    requestId: 0
                ))
            }
            
            return 0
            
        } else {
            
            return underlyingImageSource.requestImage(options: options) {
                [weak self] (result: ImageRequestResult<CGImageWrapper>) in
                
                // Cache the highest quality image
                if let image = result.image where !result.degraded {
                    self?.cache.setObject(image, forKey: cacheKey)
                }
                
                resultHandler(ImageRequestResult(
                    image: (result.image?.image).flatMap { T(CGImage: $0) },
                    degraded: result.degraded,
                    requestId: result.requestId
                ))
            }
        }
    }
    
    public func cancelRequest(id: ImageRequestId) {
        underlyingImageSource.cancelRequest(id)
    }
    
    public func isEqualTo(other: ImageSource) -> Bool {
        return (other as? CachingImageSource).flatMap { underlyingImageSource.isEqualTo($0.underlyingImageSource) } ?? false
    }
}

private final class ImageRequestCacheKey: Equatable {
    
    let size: ImageSizeOption
    
    init(size: ImageSizeOption) {
        self.size = size
    }
}

private func ==(r1: ImageRequestCacheKey, r2: ImageRequestCacheKey) -> Bool {
    return r1.size == r2.size
}