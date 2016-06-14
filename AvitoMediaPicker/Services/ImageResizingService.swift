import Foundation
import CoreGraphics
import ImageIO
import MobileCoreServices

protocol ImageResizingService {
    func resizeImage(atPath path: String, toPixelSize: CGSize, completion: CGImage? -> ())
}

final class ImageResizingServiceImpl: ImageResizingService {
    
    func resizeImage(atPath path: String, toPixelSize size: CGSize, completion: CGImage? -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let inputUrl = NSURL(fileURLWithPath: path, isDirectory: false)
            
            if let imageSource = CGImageSourceCreateWithURL(inputUrl, nil) {
                
                let options: [NSString: NSObject] = [
                    kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceCreateThumbnailFromImageAlways: true
                ]
                
                let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(image)
                }
            }
        }
    }
}