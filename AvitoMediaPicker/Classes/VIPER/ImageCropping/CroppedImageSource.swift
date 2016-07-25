import CoreGraphics
import ImageIO
import MobileCoreServices

public final class CroppedImageSource: ImageSource {
    
    public let originalImage: ImageSource
    
    let croppingParameters: ImageCroppingParameters
    private var croppedImage: CGImage?
    
    init(originalImage: ImageSource, parameters: ImageCroppingParameters) {
        self.originalImage = originalImage
        self.croppingParameters = parameters
    }
    
    // MARK: - ImageSource
    
    public func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        if let croppedImage = croppedImage {
            completion(T(CGImage: croppedImage))
        } else {
            performCrop { [weak self] in
                completion(self?.croppedImage.flatMap { T(CGImage: $0) })
            }
        }
    }
    
    public func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {
        if let croppedImage = croppedImage {
            completion(T(CGImage: croppedImage))
        } else {
            performCrop { [weak self] in
                completion(self?.croppedImage.flatMap { T(CGImage: $0) })
            }
        }
    }
    
    public func imageSize(completion: CGSize? -> ()) {
        // TODO
    }
    
    public func writeImageToUrl(url: NSURL, completion: Bool -> ()) {
        // TODO
    }
    
    // MARK: - Private
    
    private func performCrop(completion: () -> ()) {
        
        originalImage.fullResolutionImage { [weak self] (imageWrapper: CGImageWrapper?) in
            
            if let originalCGImage = imageWrapper?.image, croppedCGImage = self?.newTransformedImage(originalCGImage) {
                self?.croppedImage = croppedCGImage
            }
            
            completion()
        }
    }
    
    private func newTransformedImage(sourceImage: CGImage) -> CGImage? {
        
        let source = newScaledImage(
            sourceImage,
            withOrientation: croppingParameters.sourceOrientation,
            toSize: croppingParameters.sourceSize,
            withQuality: .None
        )
        
        let cropSize = croppingParameters.cropSize
        let outputWidth = croppingParameters.outputWidth
        let transform = croppingParameters.transform
        let imageViewSize = croppingParameters.imageViewSize
        
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