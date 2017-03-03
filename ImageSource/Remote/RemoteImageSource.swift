import ImageIO
import MobileCoreServices

public class RemoteImageSource: ImageSource {
    
    // MARK: - Init
    
    public init(url: URL, previewImage: CGImage? = nil, imageDownloader: CachingImageDownloader) {
        self.url = url
        self.previewImage = previewImage
        self.imageDownloader = imageDownloader
    }

    // MARK: - ImageSource
    
    public func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        
        let operation = fullResolutionImageRequestOperation(resultHandler: { (imageWrapper: CGImageWrapper?) in
            SharedQueues.imageProcessingQueue.addOperation {
                let data = NSMutableData()
                let cgImage = imageWrapper?.image
                let destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil)
                
                if let cgImage = cgImage, let destination = destination {
                    CGImageDestinationAddImage(destination, cgImage, nil)
                    CGImageDestinationFinalize(destination)
                    
                    DispatchQueue.main.async { completion(data as Data) }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        })
        
        RemoteImageSource.requestsQueue.addOperation(operation)
    }
    
    public func imageSize(completion: @escaping (CGSize?) -> ()) {
        if let fullSize = fullSize {
            dispatch_to_main_queue { completion(fullSize) }
        } else {
            let operation = fullResolutionImageRequestOperation(resultHandler: { [weak self] (image: UIImage?) in
                DispatchQueue.main.async {
                    self?.fullSize = image?.size
                    completion(image?.size)
                }
            })
            
            RemoteImageSource.requestsQueue.addOperation(operation)
        }
    }

    @discardableResult
    public func requestImage<T : InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        let requestId = RemoteImageSource.requestIdsGenerator.nextInt().toImageRequestId()
        let cachedImage = imageDownloader.cachedImageForUrl(url)
        
        if let previewImage = previewImage ?? cachedImage, options.deliveryMode == .progressive {
            dispatch_to_main_queue {
                resultHandler(ImageRequestResult(image: T(cgImage: previewImage), degraded: true, requestId: requestId))
            }
        }
        
        let operation = RemoteImageRequestOperation(
            id: requestId,
            url: url,
            options: options,
            resultHandler: resultHandler,
            imageDownloader: imageDownloader
        )
        
        RemoteImageSource.requestsQueue.addOperation(operation)
        
        return requestId
    }
    
    public func cancelRequest(_ id: ImageRequestId) {
        for operation in RemoteImageSource.requestsQueue.operations {
            if let identifiableOperation = operation as? ImageRequestIdentifiable, identifiableOperation.id == id {
                operation.cancel()
            }
        }
    }
    
    public func isEqualTo(_ other: ImageSource) -> Bool {
        return (other as? RemoteImageSource).flatMap { $0.url == url } ?? false
    }
    
    // MARK: - Private
    
    private static let requestIdsGenerator = ThreadSafeIntGenerator()
    
    private static let requestsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    private let url: URL
    private let previewImage: CGImage?
    private var fullSize: CGSize?
    
    private let imageDownloader: CachingImageDownloader
    
    private func fullResolutionImageRequestOperation<T: InitializableWithCGImage>(resultHandler: @escaping (T?) -> ()) -> RemoteImageRequestOperation<T> {
        
        let requestId = RemoteImageSource.requestIdsGenerator.nextInt().toImageRequestId()
        let options = ImageRequestOptions(size: .fullResolution, deliveryMode: .best)
        
        return RemoteImageRequestOperation(
            id: requestId,
            url: url,
            options: options,
            resultHandler: { (result: ImageRequestResult<T>) in
                resultHandler(result.image)
            },
            imageDownloader: imageDownloader
        )
    }
}

public typealias UrlImageSource = RemoteImageSource
