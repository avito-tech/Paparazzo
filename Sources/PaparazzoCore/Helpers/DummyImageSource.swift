import ImageSource
import UIKit

final class DummyImageSource: ImageSource {
    
    let id = UUID()
    let color = UIColor.random()
    
    private let size = CGSize(width: 1, height: 1)
    
    @discardableResult
    func requestImage<T: InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        let requestId = ImageRequestId(hashable: id)
        
        defer {
            let cgImage = UIImage.imageWithColor(color, imageSize: size)?.cgImage
            let result = ImageRequestResult(
                image: cgImage.flatMap { T(cgImage: $0) },
                degraded: false,
                requestId: requestId
            )
            resultHandler(result)
        }
        
        return requestId
    }
    
    func cancelRequest(_: ImageRequestId) {}
    
    func imageSize(completion: @escaping (CGSize?) -> ()) {
        completion(size)
    }
    
    func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        completion(nil)
    }

    func isEqualTo(_ other: ImageSource) -> Bool {
        return (other as? DummyImageSource).flatMap { id == $0.id } ?? false
    }
}
