import Foundation
import ImageIO
import MobileCoreServices

/// Operation for requesting images stored in a local file.
final class LocalImageRequestOperation<T: InitializableWithCGImage>: NSOperation, ImageRequestIdentifiable {
    
    let id: ImageRequestId
    
    private let path: String
    private let options: ImageRequestOptions
    private let resultHandler: (image: T?, requestId: ImageRequestId) -> ()
    private let callbackQueue: dispatch_queue_t
    
    // Можно сделать failable/throwing init, который будет возвращать nil/кидать исключение, если url не файловый,
    // но пока не вижу в этом особой необходимости
    init(id: ImageRequestId,
         path: String,
         options: ImageRequestOptions,
         resultHandler: (image: T?, requestId: ImageRequestId) -> (),
         callbackQueue: dispatch_queue_t = dispatch_get_main_queue())
    {
        self.id = id
        self.path = path
        self.options = options
        self.resultHandler = resultHandler
        self.callbackQueue = callbackQueue
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
        
        guard !cancelled else { return }
        let url = NSURL(fileURLWithPath: path)
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
        dispatch_async(callbackQueue) { [resultHandler, id] in
            resultHandler(
                image: cgImage.flatMap { T(CGImage: $0) },
                requestId: id
            )
        }
    }
    
    private func getImageResizedTo(size: CGSize) {
        
        guard !cancelled else { return }
        let url = NSURL(fileURLWithPath: path)
        let source = CGImageSourceCreateWithURL(url, nil)
        
        let options: [NSString: NSObject] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        guard !cancelled else { return }
        let cgImage = source.flatMap { CGImageSourceCreateThumbnailAtIndex($0, 0, options) }
        
        guard !cancelled else { return }
        dispatch_async(callbackQueue) { [resultHandler, id] in
            resultHandler(
                image: cgImage.flatMap { T(CGImage: $0) },
                requestId: id
            )
        }
    }
}

protocol ImageRequestIdentifiable {
    var id: ImageRequestId { get }
}