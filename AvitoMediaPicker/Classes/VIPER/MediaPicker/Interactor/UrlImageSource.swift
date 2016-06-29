import Foundation
import ImageIO
import MobileCoreServices

struct UrlImageSource: ImageSource {

    private let url: NSURL
    private let cache = NSCache()

    init(url: NSURL) {
        self.url = url
    }

    // MARK: - ImageSource
    
    func writeImageToUrl(url: NSURL, completion: Bool -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [url] in
            
            var success = false
            
            let source = CGImageSourceCreateWithURL(url, nil)
            // TODO: тип картинки определять по расширению целевого файла
            let destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, nil)
            
            if let source = source, destination = destination {
                CGImageDestinationAddImageFromSource(destination, source, 0, nil)
                success = CGImageDestinationFinalize(destination)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(success)
            }
        }
    }

    func fullResolutionImage<T: InitializableWithCGImage>(completion: (T?) -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [url] in
         
            let source = CGImageSourceCreateWithURL(url, nil)
            let cgImage = source.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(cgImage.flatMap { T(CGImage: $0) })
            }
        }
    }

    func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: (T?) -> ()) {
        
        let cacheKey = NSValue(CGSize: size)
        
        if let cachedCGImage = cache.objectForKey(cacheKey) {
            // Force unwrapping, потому что "Cast to Core Foundation types always succeeds in runtime"
            completion(T(CGImage: cachedCGImage as! CGImage))
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [url, cache] in

            let source = CGImageSourceCreateWithURL(url, nil)

            let options: [NSString: NSObject] = [
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true
            ]

            let cgImage = source.flatMap { CGImageSourceCreateThumbnailAtIndex($0, 0, options) }
            
            if let cgImage = cgImage {
                cache.setObject(cgImage, forKey: cacheKey)
            }

            dispatch_async(dispatch_get_main_queue()) {
                completion(cgImage.flatMap { T(CGImage: $0) })
            }
        }
    }
}
