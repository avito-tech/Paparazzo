import Foundation
import ImageIO
import MobileCoreServices
import AvitoDesignKit

public final class UrlImageSource: ImageSource {
    
    private static let requestIdsGenerator = ThreadSafeIntGenerator()
    
    private static let processingQueue: NSOperationQueue = {
        
        let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        
        /*
         Это фиксит ситуацию на iPhone 4, когда создавалось слишком много потоков для операций запроса фотки,
         и суммарная используемая ими память порождала крэш из-за нехватки памяти. Данное решение не приводит к
         лагам, работает шустро даже на iPhone 4.
         
         TODO: (ayutkin) В дальнейшем нужно сделать возможность отмены операций, которые создаются в requestImage,
         и отменять их из UI — например, при переключении между фотками в пикере.
         */
        queue.maxConcurrentOperationCount = 3
        
        return queue
    }()

    private let url: NSURL
    private let previewImage: CGImage?

    public init(url: NSURL, previewImage: CGImage? = nil) {
        self.url = url
        self.previewImage = previewImage
    }

    // MARK: - ImageSource
    
    public func fullResolutionImageData(completion: NSData? -> ()) {
        UrlImageSource.processingQueue.addOperationWithBlock { [url] in
            let data = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue()) {
                completion(data)
            }
        }
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        
        UrlImageSource.processingQueue.addOperationWithBlock { [url] in
            
            let source = CGImageSourceCreateWithURL(url, nil)
            let options = source.flatMap { CGImageSourceCopyPropertiesAtIndex($0, 0, nil) } as Dictionary?
            let width = options?[kCGImagePropertyPixelWidth] as? Int
            let height = options?[kCGImagePropertyPixelHeight] as? Int
            let orientation = options?[kCGImagePropertyOrientation] as? Int
            
            var size: CGSize? = nil
            
            if let width = width, height = height {
                
                let exifOrientation = orientation.flatMap { ExifOrientation(rawValue: $0) }
                let dimensionsSwapped = exifOrientation.flatMap { $0.dimensionsSwapped } ?? false
                
                size = CGSize(
                    width: dimensionsSwapped ? height : width,
                    height: dimensionsSwapped ? width : height
                )
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(size)
            }
        }
    }

    public func requestImage<T : InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: T? -> ())
        -> ImageRequestID
    {
        if let previewImage = previewImage where options.deliveryMode == .Progressive {
            dispatch_to_main_queue {
                resultHandler(T(CGImage: previewImage))
            }
        }
        
        let requestId = ImageRequestID(UrlImageSource.requestIdsGenerator.nextInt())
        
        let operation = UrlImageRequestOperation(
            id: requestId,
            url: url,
            options: options,
            resultHandler: resultHandler
        )
        
        UrlImageSource.processingQueue.addOperation(operation)
        
        return requestId
    }
    
    public func cancelRequest(id: ImageRequestID) {
        for operation in UrlImageSource.processingQueue.operations {
            if let identifiableOperation = operation as? ImageRequestIdentifiable where identifiableOperation.id == id {
                operation.cancel()
            }
        }
    }
    
    public func isEqualTo(other: ImageSource) -> Bool {
        if let other = other as? UrlImageSource {
            return other.url == url
        } else {
            return false
        }
    }
}
