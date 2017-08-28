import Paparazzo
import ImageSource
import ImageIO
import CoreGraphics
import MobileCoreServices

final class AutoAdjustmentFilter: Filter {
    let fallbackMessage: String? = "Cannot do anything aaaaaaa".uppercased()
    
    func apply(_ sourceImage: ImageSource, completion: @escaping ((_ resultImage: ImageSource) -> ())) {
        
        let options = ImageRequestOptions(size: .fullResolution, deliveryMode: .best)
        
        sourceImage.requestImage(options: options) { [weak self] (result: ImageRequestResult<UIImage>) in
            guard let image = result.image else  {
                completion(sourceImage)
                return
            }
            
            var ciImage = CIImage(image: image)
            let adjustments = ciImage?.autoAdjustmentFilters()
            
            adjustments?.forEach { filter in
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                ciImage = filter.outputImage
            }
            
            let context = CIContext(options: nil)
            if let output = ciImage, let cgImage = context.createCGImage(output, from: output.extent) {
                
                if let image = self?.imageSource(with: cgImage) {
                    completion(image)
                    return
                }
            }
            
            completion(sourceImage)
        }
    }
    
    private func imageSource(with cgImage: CGImage) -> ImageSource? {
        
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(UUID().uuidString).jpg")
        let url = URL(fileURLWithPath: path)
        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil)
        
        if let destination = destination {
            
            CGImageDestinationAddImage(destination, cgImage, nil)
            
            if CGImageDestinationFinalize(destination) {
                let imageSource = LocalImageSource(path: path, previewImage: cgImage)
                return imageSource
            }
        }
        return nil
    }
}
