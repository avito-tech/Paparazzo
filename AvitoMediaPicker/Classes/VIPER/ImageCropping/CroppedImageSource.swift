import CoreGraphics
import ImageIO
import MobileCoreServices
import AvitoDesignKit

final class CroppedImageSource: ImageSource {
    
    let originalImage: ImageSource
    var croppingParameters: ImageCroppingParameters?
    var previewImage: CGImage?
    
    private let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
    
    init(originalImage: ImageSource, parameters: ImageCroppingParameters?, previewImage: CGImage?) {
        self.originalImage = originalImage
        self.croppingParameters = parameters
        self.previewImage = previewImage
    }
    
    // MARK: - ImageSource
    
    func fullResolutionImage<T : InitializableWithCGImage>(deliveryMode deliveryMode: ImageDeliveryMode, resultHandler: T? -> ()) {
        if let previewImage = previewImage where deliveryMode == .Progressive {
            resultHandler(T(CGImage: previewImage))
        }
        
        // TODO
        getCroppedImage { cgImage in
            resultHandler(cgImage.flatMap { T(CGImage: $0) })
        }
    }
    
    func fullResolutionImageData(completion: NSData? -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let data = NSMutableData()
            let destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil)
            
            if let image = self.croppedImage, destination = destination {
                CGImageDestinationAddImage(destination, image, nil)
                CGImageDestinationFinalize(destination)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(data.length > 0 ? NSData(data: data) : nil)
            }
        }
    }
    
    func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: ImageContentMode,
        deliveryMode: ImageDeliveryMode,
        resultHandler: T? -> ())
        -> ImageRequestID
    {
        if let previewImage = previewImage where deliveryMode == .Progressive {
            resultHandler(T(CGImage: previewImage))
        }
        
        // TODO
        getCroppedImage { cgImage in
            resultHandler(cgImage.flatMap { T(CGImage: $0) })
        }
        
        return 0    // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
    }
    
    func cancelRequest(requestID: ImageRequestID) {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
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
    
    private let croppedImageCache = SingleObjectCache<CGImageWrapper>()
    
    private var croppedImage: CGImage? {
        get { return croppedImageCache.value?.image }
        set { croppedImageCache.value = newValue.flatMap { CGImageWrapper(CGImage: $0) } }
    }
    
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
            
            if let originalCGImage = imageWrapper?.image, croppingParameters = self?.croppingParameters {
                self?.croppedImage = self?.newTransformedImage(originalCGImage, parameters: croppingParameters)
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
    ) -> CGImage {
        
        let ciImage = CIImage(CGImage: source)
        
        let transform = CGAffineTransformIdentity
            .translate(dx: size.width / 2, dy: size.height / 2)
            .append(ciImage.imageTransformForOrientation(Int32(orientation.rawValue)))
            .translate(dx: -size.width / 2, dy: -size.height / 2)
        
        return ciContext.createCGImage(
            ciImage.imageByApplyingTransform(transform),
            fromRect: CGRect(origin: .zero, size: size)
        )
    }
}