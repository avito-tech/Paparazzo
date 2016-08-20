import Foundation
import ImageIO
import MobileCoreServices

final class UrlImageRequestOperation<T: InitializableWithCGImage>: NSOperation, ImageRequestIdentifiable {
    
    let id: ImageRequestID
    
    private let url: NSURL
    private let options: ImageRequestOptions
    private let resultHandler: T? -> ()
    private let resultQueue: dispatch_queue_t
    
    init(id: ImageRequestID,
         url: NSURL,
         options: ImageRequestOptions,
         resultHandler: T? -> (),
         resultQueue: dispatch_queue_t = dispatch_get_main_queue())
    {
        self.id = id
        self.url = url
        self.options = options
        self.resultHandler = resultHandler
        self.resultQueue = resultQueue
    }
    
    override func main() {
        switch options.size {
        case .FullResolution:
            getFullResolutionImage()
        case .FillSize(let size):
            getImageResizedTo(size)
        case .FitSize(let size):
            getImageResizedTo(size)
        }
    }
    
    // MARK: - Private
    
    private func getFullResolutionImage() {
        
        let source = CGImageSourceCreateWithURL(url, nil)
        
        let options = source.flatMap { CGImageSourceCopyPropertiesAtIndex($0, 0, nil) } as Dictionary?
        let orientation = options?[kCGImagePropertyOrientation] as? Int
        
        guard !cancelled else { return }
        var cgImage = source.flatMap { CGImageSourceCreateImageAtIndex($0, 0, options) }
        
        if let exifOrientation = orientation.flatMap({ ExifOrientation(rawValue: $0) }) {
            guard !cancelled else { return }
            cgImage = cgImage?.imageFixedForOrientation(exifOrientation)
        }
        
        guard !cancelled else { return }
        dispatch_async(resultQueue) { [resultHandler] in
            resultHandler(cgImage.flatMap { T(CGImage: $0) })
        }
    }
    
    private func getImageResizedTo(size: CGSize) {
        
        let source = CGImageSourceCreateWithURL(url, nil)
        
        let options: [NSString: NSObject] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        guard !cancelled else { return }
        let cgImage = source.flatMap { CGImageSourceCreateThumbnailAtIndex($0, 0, options) }
        
        guard !cancelled else { return }
        dispatch_async(resultQueue) { [resultHandler] in
            resultHandler(cgImage.flatMap { T(CGImage: $0) })
        }
    }
}

protocol ImageRequestIdentifiable {
    var id: ImageRequestID { get }
}