import Foundation
import CoreGraphics
import ImageIO
import MobileCoreServices

final class ImageCroppingInteractorImpl: ImageCroppingInteractor {
    
    private let originalImage: ImageSource
    private var parameters: ImageCroppingParameters?
    
    init(originalImage: ImageSource) {
        self.originalImage = originalImage
    }
    
    // MARK: - CroppingInteractor
    
    func setCroppingParameters(parameters: ImageCroppingParameters) {
        self.parameters = parameters
    }
    
    func performCrop(completion: ImageSource -> ()) {
        
        guard let parameters = parameters else {
            return completion(originalImage)
        }
        
        originalImage.fullResolutionImage { [weak self] (imageWrapper: CGImageWrapper?) in
            
            if let image = imageWrapper?.image {
                if let image = self?.newTransformedImage(image, parameters: parameters) {
                    let url = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())/test_crop.jpg", isDirectory: false)
                    if let destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, nil) {
                        CGImageDestinationAddImage(destination, image, nil)
                        CGImageDestinationFinalize(destination)
                    }
                    completion(self!.originalImage) // TODO
                }
            } else if let originalImage = self?.originalImage {
                completion(originalImage)
            }
        }
    }
    
    // MARK: - Private
    
    private func newTransformedImage(sourceImage: CGImage, parameters: ImageCroppingParameters) -> CGImage? {
        
        let source = newScaledImage(
            sourceImage,
            withOrientation: parameters.sourceOrientation,
            toSize: parameters.sourceSize,
            withQuality: .None
        )
        
        let cropSize = parameters.cropSize
        let outputWidth = parameters.outputWidth
        let transform = parameters.transform
        let imageViewSize = parameters.imageViewSize
        
        let aspect = cropSize.height / cropSize.width
        let outputSize = CGSize(width: outputWidth, height: outputWidth * aspect)
        
        let context = CGBitmapContextCreate(
            nil,
            Int(outputSize.width),
            Int(outputSize.height),
            CGImageGetBitsPerComponent(source),
            0,
            CGImageGetColorSpace(source),
            CGImageGetBitmapInfo(source).rawValue
        )
        
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextFillRect(context, CGRect(origin: .zero, size: outputSize))
        
        var uiCoords = CGAffineTransformMakeScale(
            outputSize.width / cropSize.width,
            outputSize.height / cropSize.height
        )
        
        uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width / 2, cropSize.height / 2)
        uiCoords = CGAffineTransformScale(uiCoords, 1, -1)
        
        CGContextConcatCTM(context, uiCoords)
        CGContextConcatCTM(context, transform)
        CGContextScaleCTM(context, 1, -1)
        
        CGContextDrawImage(
            context,
            CGRect(
                x: -imageViewSize.width / 2,
                y: -imageViewSize.height / 2,
                width: imageViewSize.width,
                height: imageViewSize.height
            ),
            source
        )
        
        return CGBitmapContextCreateImage(context)
    }
    
    private func newScaledImage(
        source: CGImage,
        withOrientation orientation: ExifOrientation,
        toSize size: CGSize,
        withQuality quality: CGInterpolationQuality
    ) -> CGImage? {
        
        var srcSize = size
        var rotation = CGFloat(0)
        
        switch(orientation) {
        case .Up:
            rotation = 0
        case .Down:
            rotation = CGFloat(M_PI)
        case .Left:
            rotation = CGFloat(M_PI_2)
            srcSize = CGSize(width: size.height, height: size.width)
        case .Right:
            rotation = -CGFloat(M_PI_2)
            srcSize = CGSize(width: size.height, height: size.width)
        default:
            break
        }
        
        let context = CGBitmapContextCreate(
            nil,
            Int(size.width),
            Int(size.height),
            8,  //CGImageGetBitsPerComponent(source),
            0,
            CGImageGetColorSpace(source),
            CGImageGetBitmapInfo(source).rawValue  // kCGImageAlphaNoneSkipFirst
        )
        
        CGContextSetInterpolationQuality(context, quality)
        CGContextTranslateCTM(context, size.width / 2, size.height / 2)
        CGContextRotateCTM(context, rotation)
        
        CGContextDrawImage(
            context,
            CGRect(
                x: -srcSize.width / 2,
                y: -srcSize.height / 2,
                width: srcSize.width,
                height: srcSize.height
            ),
            source
        )
        
        return CGBitmapContextCreateImage(context)
    }
}
