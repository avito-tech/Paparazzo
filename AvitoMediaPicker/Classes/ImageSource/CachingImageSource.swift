import CoreGraphics
import AvitoDesignKit

@available(*, deprecated, message="Оно не очень хорошо работает, лучше для разных ImageSource'ов делать свою логику кэширования")
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
        resultHandler: T? -> ())
        -> ImageRequestID
    {
        let cacheKey = ImageRequestCacheKey(size: options.size)
        
        if let cachedImageWrapper = cache.objectForKey(cacheKey) as? CGImageWrapper {
            resultHandler(T(CGImage: cachedImageWrapper.image))
            return 0
            
        } else {
            
            let requestID: ImageRequestID
            
            switch options.deliveryMode {
            
            case .Progressive:
                requestID = underlyingImageSource.requestImage(options: options, resultHandler: resultHandler)
                
                var bestImageOptions = options
                bestImageOptions.deliveryMode = .Best
                
                // Для кэша нужна самая лучшая версия картинки
                underlyingImageSource.requestImage(options: bestImageOptions) { [weak self] (imageWrapper: CGImageWrapper?) in
                    if let imageWrapper = imageWrapper {
                        self?.cache.setObject(imageWrapper, forKey: cacheKey)
                    }
                }
                
            case .Best:
                requestID = underlyingImageSource.requestImage(options: options) { [weak self] (imageWrapper: CGImageWrapper?) in
                    if let imageWrapper = imageWrapper {
                        self?.cache.setObject(imageWrapper, forKey: cacheKey)
                    }
                    resultHandler(imageWrapper.flatMap { T(CGImage: $0.image) })
                }
            }
            
            return requestID
        }
    }
    
    public func cancelRequest(id: ImageRequestID) {
        underlyingImageSource.cancelRequest(id)
    }
    
    public func isEqualTo(other: ImageSource) -> Bool {
        guard let other = other as? CachingImageSource
            else { return false }
        
        return underlyingImageSource.isEqualTo(other.underlyingImageSource)
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