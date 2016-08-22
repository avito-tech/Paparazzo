import Foundation
import ImageIO
import MobileCoreServices
import AvitoDesignKit

public class UrlImageSource: ImageSource {
    
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
    private var fullSize: CGSize?

    public init(url: NSURL, previewImage: CGImage? = nil) {
        self.url = url
        self.previewImage = previewImage
    }

    // MARK: - ImageSource
    
    public func fullResolutionImageData(completion: NSData? -> ()) {
        
        if url.fileURL {
            
            UrlImageSource.processingQueue.addOperationWithBlock { [url] in
                let data = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(data)
                }
            }
            
        } else {
            
            UrlImageSource.processingQueue.addOperation(fullResolutionRemoteImageRequestOperation { (imageWrapper: CGImageWrapper?) in
                
                let data = NSMutableData()
                
                if let cgImage = imageWrapper?.image, destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil) {
                    CGImageDestinationAddImage(destination, cgImage, nil)
                    CGImageDestinationFinalize(destination)
                    
                    dispatch_async(dispatch_get_main_queue()) { completion(NSData(data: data)) }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { completion(nil) }
                }
            })
        }
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        if let fullSize = fullSize {
            dispatch_to_main_queue { completion(fullSize) }
        } else if url.fileURL {
            getLocalImageSize(completion)
        } else {
            getRemoteImageSize(completion)
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
        let operation: NSOperation
        
        if url.fileURL {
            operation = LocalImageRequestOperation(id: requestId, url: url, options: options, resultHandler: resultHandler)
        } else {
            operation = RemoteImageRequestOperation(id: requestId, url: url, options: options, resultHandler: resultHandler)
        }
        
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
    
    // MARK: - Private
    
    private func getLocalImageSize(completion: CGSize? -> ()) {
        
        UrlImageSource.processingQueue.addOperationWithBlock { [weak self, url] in
            
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
                self?.fullSize = size
                completion(size)
            }
        }
    }
    
    private func getRemoteImageSize(completion: CGSize? -> ()) {
        UrlImageSource.processingQueue.addOperation(fullResolutionRemoteImageRequestOperation { [weak self] (image: UIImage?) in
            dispatch_async(dispatch_get_main_queue()) {
                self?.fullSize = image?.size
                completion(image?.size)
            }
        })
    }
    
    private func fullResolutionRemoteImageRequestOperation<T : InitializableWithCGImage>(resultHandler: T? -> ()) -> RemoteImageRequestOperation<T> {
        
        let requestId = ImageRequestID(UrlImageSource.requestIdsGenerator.nextInt())
        let options = ImageRequestOptions(size: .FullResolution, deliveryMode: .Best)

        return RemoteImageRequestOperation(id: requestId, url: url, options: options, resultHandler: resultHandler)
    }
}
