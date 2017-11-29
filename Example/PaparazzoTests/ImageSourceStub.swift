@testable import ImageSource
import MobileCoreServices

final class ImageSourceStub: ImageSource {
    
    // MARK: - Data
    private let size: CGSize
    private let color: CGColor
    private let loadingTime: TimeInterval
    
    // MARK: - State
    private var cancelledRequestIds = Set<ImageRequestId>()
    private var nextRequestId = Int32(1)
    
    // MARK: - Init
    init(
        size: CGSize = CGSize(width: 1, height: 1),
        color: CGColor = UIColor.green.cgColor,
        loadingTime: TimeInterval = 1)
    {
        self.size = size
        self.color = color
        self.loadingTime = loadingTime
    }
    
    // MARK: - ImageSource
    @discardableResult
    public func requestImage<T: InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        let requestId = nextRequestId.toImageRequestId()
        let image = self.image()
        
        nextRequestId += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingTime) { [weak self] in
            if self?.cancelledRequestIds.contains(requestId) != true {
                resultHandler(ImageRequestResult(
                    image: image.flatMap { T(cgImage: $0) },
                    degraded: false,
                    requestId: requestId
                ))
            }
        }
        
        return requestId
    }
    
    func cancelRequest(_ requestId: ImageRequestId) {
        cancelledRequestIds.insert(requestId)
    }
    
    func imageSize(completion: @escaping (CGSize?) -> ()) {
        completion(size)
    }
    
    func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil)
        
        if let cgImage = image(), let destination = destination {
            CGImageDestinationAddImage(destination, cgImage, nil)
            CGImageDestinationFinalize(destination)
            completion(data as Data)
        } else {
            completion(nil)
        }
    }
    
    func isEqualTo(_ other: ImageSource) -> Bool {
        return self === other
    }
    
    // MARK: - Private
    private func image() -> CGImage? {
        
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image?.cgImage
    }
}
