import Foundation
import CoreGraphics
import ImageIO
import MobileCoreServices

protocol ImageResizingService {
    func resizeImage(atPath path: String, toSize: CGSize, outputPath: String, completion: (success: Bool) -> ())
}

final class ImageResizingServiceImpl: ImageResizingService {
    
    func resizeImage(atPath path: String, toSize size: CGSize, outputPath: String, completion: (success: Bool) -> ()) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let inputUrl = NSURL(fileURLWithPath: path, isDirectory: false)
            let outputUrl = NSURL(fileURLWithPath: outputPath, isDirectory: false)
            
            if let imageSource = CGImageSourceCreateWithURL(inputUrl, nil) {
                
                let options: [NSString: NSObject] = [
                    kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceCreateThumbnailFromImageAlways: true
                ]
                
                if let thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options),
                    destination = CGImageDestinationCreateWithURL(outputUrl, kUTTypePNG, 1, nil) {
                    
                    CGImageDestinationAddImage(destination, thumbnailImage, nil)
                    
                    completion(success: CGImageDestinationFinalize(destination))
                    
                } else {
                    completion(success: false)
                }
            }
        }
    }
}
