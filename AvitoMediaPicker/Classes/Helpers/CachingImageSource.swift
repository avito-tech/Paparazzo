import CoreGraphics
import AvitoDesignKit

final class CachingImageSource: ImageSource {
    
    private let underlyingImageSource: ImageSource
    private let cache = NSCache()
    
    init(underlyingImageSource: ImageSource) {
        // Не даем создавать вложенные CachingImageSource
        if let cachingImageSource = underlyingImageSource as? CachingImageSource {
            self.underlyingImageSource = cachingImageSource.underlyingImageSource
        } else {
            self.underlyingImageSource = underlyingImageSource
        }
    }
    
    // MARK: - ImageSource
    
    func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        underlyingImageSource.fullResolutionImage(completion)
    }
    
    func imageSize(completion: CGSize? -> ()) {
        underlyingImageSource.imageSize(completion)
    }
    
    func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {
        
        let cacheKey = NSValue(CGSize: size)
        
        if let cachedImageWrapper = cache.objectForKey(cacheKey) as? CGImageWrapper {
            completion(T(CGImage: cachedImageWrapper.image))
        } else {
            underlyingImageSource.imageFittingSize(size, contentMode: contentMode) { [weak self] (imageWrapper: CGImageWrapper?) in
                
                let cgImage = imageWrapper?.image
                
                if let imageWrapper = imageWrapper {
                    self?.cache.setObject(imageWrapper, forKey: cacheKey)
                }
                
                completion(cgImage.flatMap { T(CGImage: $0) })
            }
        }
    }
    
    func isEqualTo(other: ImageSource) -> Bool {
        guard let other = other as? CachingImageSource
            else { return false }
        
        return underlyingImageSource.isEqualTo(other.underlyingImageSource)
    }
}