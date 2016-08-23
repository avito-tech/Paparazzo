import ImageIO
import MobileCoreServices

public class RemoteImageSource: ImageSource {
    
    // MARK: - Init

    public init(url: NSURL, previewImage: CGImage? = nil) {
        self.url = url
        self.previewImage = previewImage
    }

    // MARK: - ImageSource
    
    public func fullResolutionImageData(completion: NSData? -> ()) {
        
        let operation = fullResolutionImageRequestOperation(resultHandler: { (imageWrapper: CGImageWrapper?) in
            SharedQueues.imageProcessingQueue.addOperationWithBlock {
                let data = NSMutableData()
                let cgImage = imageWrapper?.image
                let destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil)
                
                if let cgImage = cgImage, destination = destination {
                    CGImageDestinationAddImage(destination, cgImage, nil)
                    CGImageDestinationFinalize(destination)
                    
                    dispatch_async(dispatch_get_main_queue()) { completion(NSData(data: data)) }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { completion(nil) }
                }
            }
        })
        
        RemoteImageSource.requestsQueue.addOperation(operation)
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        if let fullSize = fullSize {
            dispatch_to_main_queue { completion(fullSize) }
        } else {
            let operation = fullResolutionImageRequestOperation(resultHandler: { [weak self] (image: UIImage?) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.fullSize = image?.size
                    completion(image?.size)
                }
            })
            
            RemoteImageSource.requestsQueue.addOperation(operation)
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
        
        let requestId = ImageRequestID(RemoteImageSource.requestIdsGenerator.nextInt())
        
        let operation = RemoteImageRequestOperation(
            id: requestId,
            url: url,
            options: options,
            resultHandler: resultHandler
        )
        
        RemoteImageSource.requestsQueue.addOperation(operation)
        
        return requestId
    }
    
    public func cancelRequest(id: ImageRequestID) {
        for operation in RemoteImageSource.requestsQueue.operations {
            if let identifiableOperation = operation as? ImageRequestIdentifiable where identifiableOperation.id == id {
                operation.cancel()
            }
        }
    }
    
    public func isEqualTo(other: ImageSource) -> Bool {
        return (other as? RemoteImageSource).flatMap { $0.url == url } ?? false
    }
    
    // MARK: - Private
    
    private static let requestIdsGenerator = ThreadSafeIntGenerator()
    
    private static let requestsQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        return queue
    }()
    
    private let url: NSURL
    private let previewImage: CGImage?
    private var fullSize: CGSize?
    
    private func fullResolutionImageRequestOperation<T : InitializableWithCGImage>(resultHandler resultHandler: T? -> ()) -> RemoteImageRequestOperation<T> {
        
        let requestId = ImageRequestID(RemoteImageSource.requestIdsGenerator.nextInt())
        let options = ImageRequestOptions(size: .FullResolution, deliveryMode: .Best)

        return RemoteImageRequestOperation(id: requestId, url: url, options: options, resultHandler: resultHandler)
    }
}

public typealias UrlImageSource = RemoteImageSource
