import Foundation
import ImageIO
import MobileCoreServices

public final class LocalImageSource: ImageSource {
    
    public let path: String
    
    // MARK: - Init
    
    public init(path: String, previewImage: CGImage? = nil) {
        self.path = path
        self.previewImage = previewImage
    }
    
    // MARK: - ImageSource
    
    @discardableResult
    public func requestImage<T : InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        let requestId = LocalImageSource.requestIdsGenerator.nextInt().toImageRequestId()
        
        if let previewImage = previewImage, options.deliveryMode == .progressive {
            dispatch_to_main_queue {
                resultHandler(ImageRequestResult(image: T(cgImage: previewImage), degraded: true, requestId: requestId))
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
    
    public func cancelRequest(_ id: ImageRequestId) {
        for operation in SharedQueues.imageProcessingQueue.operations {
            if let identifiableOperation = operation as? ImageRequestIdentifiable, identifiableOperation.id == id {
                operation.cancel()
            }
        }
    }
    
    public func imageSize(completion: @escaping (CGSize?) -> ()) {
        if let fullSize = fullSize {
            dispatch_to_main_queue { completion(fullSize) }
        } else {
            SharedQueues.imageProcessingQueue.addOperation { [weak self, path] in
                
                let url = NSURL(fileURLWithPath: path)
                let source = CGImageSourceCreateWithURL(url, nil)
                let options = source.flatMap { CGImageSourceCopyPropertiesAtIndex($0, 0, nil) } as Dictionary?
                let width = options?[kCGImagePropertyPixelWidth] as? Int
                let height = options?[kCGImagePropertyPixelHeight] as? Int
                let orientation = options?[kCGImagePropertyOrientation] as? Int
                
                var size: CGSize? = nil
                
                if let width = width, let height = height {
                    
                    let exifOrientation = orientation.flatMap { ExifOrientation(rawValue: $0) }
                    let dimensionsSwapped = exifOrientation.flatMap { $0.dimensionsSwapped } ?? false
                    
                    size = CGSize(
                        width: dimensionsSwapped ? height : width,
                        height: dimensionsSwapped ? width : height
                    )
                }
                
                DispatchQueue.main.async {
                    self?.fullSize = size
                    completion(size)
                }
            }
        }
    }
    
    public func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        SharedQueues.imageProcessingQueue.addOperation { [path] in
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    public func isEqualTo(_ other: ImageSource) -> Bool {
        return (other as? LocalImageSource).flatMap { $0.path == path } ?? false
    }
    
    // MARK: - Private
    
    private static let requestIdsGenerator = ThreadSafeIntGenerator()
    
    private let previewImage: CGImage?
    private var fullSize: CGSize?
}
