import CoreGraphics
import AvitoDesignKit

public final class CachingImageSource: ImageSource {
    
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
    
    public func fullResolutionImage<T : InitializableWithCGImage>(deliveryMode deliveryMode: ImageDeliveryMode, resultHandler: T? -> ()) {
        
        let cacheKey = "fullResolutionImage"
        
        if let cachedImageWrapper = cache.objectForKey(cacheKey) as? CGImageWrapper {
            resultHandler(T(CGImage: cachedImageWrapper.image))
            
        } else {
            
            switch deliveryMode {
                
            case .Progressive:
                underlyingImageSource.fullResolutionImage(deliveryMode: deliveryMode, resultHandler: resultHandler)
                
                // Для кэша нужна самая лучшая версия картинки
                underlyingImageSource.fullResolutionImage(deliveryMode: .Best) { [weak self] (imageWrapper: CGImageWrapper?) in
                    if let imageWrapper = imageWrapper {
                        self?.cache.setObject(imageWrapper, forKey: cacheKey)
                    }
                }
                
            case .Best:
                underlyingImageSource.fullResolutionImage(deliveryMode: deliveryMode) { [weak self] (imageWrapper: CGImageWrapper?) in
                    if let imageWrapper = imageWrapper {
                        self?.cache.setObject(imageWrapper, forKey: cacheKey)
                    }
                    resultHandler(imageWrapper.flatMap { T(CGImage: $0.image) })
                }
            }
        }
    }
    
    public func fullResolutionImageData(completion: NSData? -> ()) {
        underlyingImageSource.fullResolutionImageData(completion)
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        underlyingImageSource.imageSize(completion)
    }
    
    public func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: ImageContentMode,
        deliveryMode: ImageDeliveryMode,
        resultHandler: T? -> ())
        -> ImageRequestID
    {
        let cacheKey = ImageRequestParameters(size: size, contentMode: contentMode)
        
        if let cachedImageWrapper = cache.objectForKey(cacheKey) as? CGImageWrapper {
            resultHandler(T(CGImage: cachedImageWrapper.image))
            return 0
            
        } else {
            
            let requestID: ImageRequestID
            
            switch deliveryMode {
            
            case .Progressive:
                requestID = underlyingImageSource.imageFittingSize(size, contentMode: contentMode, deliveryMode: deliveryMode, resultHandler: resultHandler)
                
                // Для кэша нужна самая лучшая версия картинки
                underlyingImageSource.imageFittingSize(size, contentMode: contentMode, deliveryMode: .Best) { [weak self] (imageWrapper: CGImageWrapper?) in
                    if let imageWrapper = imageWrapper {
                        self?.cache.setObject(imageWrapper, forKey: cacheKey)
                    }
                }
                
            case .Best:
                requestID = underlyingImageSource.imageFittingSize(size, contentMode: contentMode, deliveryMode: deliveryMode) { [weak self] (imageWrapper: CGImageWrapper?) in
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

private final class ImageRequestParameters: Equatable {
    
    let size: CGSize
    let contentMode: ImageContentMode
    
    init(size: CGSize, contentMode: ImageContentMode) {
        self.size = size
        self.contentMode = contentMode
    }
}

private func ==(r1: ImageRequestParameters, r2: ImageRequestParameters) -> Bool {
    return r1.size == r2.size && r1.contentMode == r2.contentMode
}