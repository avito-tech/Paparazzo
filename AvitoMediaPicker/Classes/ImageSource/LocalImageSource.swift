import Foundation
import ImageIO
import MobileCoreServices

public final class LocalImageSource: ImageSource {
    
    // MARK: - Init
    
    public init(path: String, previewImage: CGImage? = nil) {
        self.path = path
        self.previewImage = previewImage
    }
    
    // MARK: - ImageSource
    
    public func requestImage<T : InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: (image: T?, requestId: ImageRequestId) -> ())
        -> ImageRequestId
    {
        let requestId = ImageRequestId(LocalImageSource.requestIdsGenerator.nextInt())
        
        if let previewImage = previewImage where options.deliveryMode == .Progressive {
            dispatch_to_main_queue {
                resultHandler(image: T(CGImage: previewImage), requestId: requestId)
            }
        }
        
        let operation = LocalImageRequestOperation(
            id: requestId,
            path: path,
            options: options,
            resultHandler: resultHandler
        )
        
        SharedQueues.imageProcessingQueue.addOperation(operation)
        
        return requestId
    }
    
    public func cancelRequest(id: ImageRequestId) {
        for operation in SharedQueues.imageProcessingQueue.operations {
            if let identifiableOperation = operation as? ImageRequestIdentifiable where identifiableOperation.id == id {
                operation.cancel()
            }
        }
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        if let fullSize = fullSize {
            dispatch_to_main_queue { completion(fullSize) }
        } else {
            SharedQueues.imageProcessingQueue.addOperationWithBlock { [weak self, path] in
                
                let url = NSURL(fileURLWithPath: path)
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
    }
    
    public func fullResolutionImageData(completion: NSData? -> ()) {
        SharedQueues.imageProcessingQueue.addOperationWithBlock { [path] in
            let data = NSData(contentsOfFile: path)
            dispatch_async(dispatch_get_main_queue()) {
                completion(data)
            }
        }
    }
    
    public func isEqualTo(other: ImageSource) -> Bool {
        return (other as? LocalImageSource).flatMap { $0.path == path } ?? false
    }
    
    // MARK: - Private
    
    private static let requestIdsGenerator = ThreadSafeIntGenerator()
    
    private let path: String
    private let previewImage: CGImage?
    private var fullSize: CGSize?
}
