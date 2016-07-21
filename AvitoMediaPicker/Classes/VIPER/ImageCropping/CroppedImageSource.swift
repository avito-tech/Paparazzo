import CoreGraphics

final class CroppedImageSource: ImageSource {
    
    private let transform: CGAffineTransform
    private let sourceImage: CGImageRef
    private let sourceSize: CGSize
    private let sourceOrientation: UIImageOrientation
    private let outputWidth: CGFloat
    private let cropSize: CGSize
    private let imageViewSize: CGSize
    
    init(
        transform: CGAffineTransform,
        sourceImage: CGImageRef,
        sourceSize: CGSize,
        sourceOrientation: UIImageOrientation,
        outputWidth: CGFloat,
        cropSize: CGSize,
        imageViewSize: CGSize
    ) {
        self.transform = transform
        self.sourceImage = sourceImage
        self.sourceSize = sourceSize
        self.sourceOrientation = sourceOrientation
        self.outputWidth = outputWidth
        self.cropSize = cropSize
        self.imageViewSize = imageViewSize
    }
    
    // MARK: - ImageSource
    
    func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        // TODO
    }
    
    func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {
        // TODO
    }
    
    func imageSize(completion: CGSize? -> ()) {
        // TODO
    }
    
    func writeImageToUrl(url: NSURL, completion: Bool -> ()) {
        // TODO
    }
    
    // MARK: - Private
    
    private func newTransformedImage() -> CGImage? {
        
        let source = newScaledImage(
            sourceImage,
            withOrientation: sourceOrientation,
            toSize: sourceSize,
            withQuality: .None
        )
        
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
        withOrientation orientation: UIImageOrientation,
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