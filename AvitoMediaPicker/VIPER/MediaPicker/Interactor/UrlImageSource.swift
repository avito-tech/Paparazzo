import Foundation
import ImageIO

struct UrlImageSource: ImageSource {

    private let url: NSURL

    init(url: NSURL) {
        self.url = url
    }

    // MARK: - ImageSource

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

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [url] in

            let source = CGImageSourceCreateWithURL(url, nil)

            let options: [NSString: NSObject] = [
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true
            ]

            let cgImage = source.flatMap { CGImageSourceCreateThumbnailAtIndex($0, 0, options) }

            dispatch_async(dispatch_get_main_queue()) {
                completion(cgImage.flatMap { T(CGImage: $0) })
            }
        }
    }
}
