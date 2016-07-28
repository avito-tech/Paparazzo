import CoreGraphics
import ImageIO
import MobileCoreServices
import AvitoDesignKit

final class CroppedImageSource: ImageSource {
    
    let originalImage: ImageSource
    var croppingParameters: ImageCroppingParameters?
    var previewImage: CGImage?
    
    init(originalImage: ImageSource, parameters: ImageCroppingParameters?, previewImage: CGImage?) {
        self.originalImage = originalImage
        self.croppingParameters = parameters
        self.previewImage = previewImage
    }
    
    // MARK: - ImageSource
    
    func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        getCroppedImage { cgImage in
            completion(cgImage.flatMap { T(CGImage: $0) })
        }
    }
    
    func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {
        
        if let previewImage = previewImage {
            completion(T(CGImage: previewImage))
        }
        
        // TODO
        getCroppedImage { cgImage in
            completion(cgImage.flatMap { T(CGImage: $0) })
        }
    }
    
    func imageSize(completion: CGSize? -> ()) {
        getCroppedImage { cgImage in
            completion(cgImage.flatMap { CGSize(width: CGImageGetWidth($0), height: CGImageGetHeight($0)) })
        }
    }
    
    func isEqualTo(other: ImageSource) -> Bool {
        if let other = other as? CroppedImageSource {
            return originalImage.isEqualTo(other.originalImage) // TODO: сравнить croppingParameters
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private var croppedImage: CGImage?
    
    private func getCroppedImage(completion: CGImage? -> ()) {
        if let croppedImage = croppedImage {
            completion(croppedImage)
        } else {
            performCrop { [weak self] in
                completion(self?.croppedImage)
            }
        }
    }
    
    private func performCrop(completion: () -> ()) {
        
        originalImage.fullResolutionImage { [weak self] (imageWrapper: CGImageWrapper?) in
            
            if let originalCGImage = imageWrapper?.image,
                croppingParameters = self?.croppingParameters,
                croppedCGImage = self?.newTransformedImage(originalCGImage, parameters: croppingParameters) {
                
                self?.croppedImage = croppedCGImage
            }
            
            completion()
        }
    }
    
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