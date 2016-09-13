import CoreGraphics
import ImageIO
import MobileCoreServices
import AvitoDesignKit

final class CroppedImageSource: ImageSource {
    
    let originalImage: ImageSource
    let sourceSize: CGSize
    var croppingParameters: ImageCroppingParameters?
    var previewImage: CGImage?
    
    init(originalImage: ImageSource, sourceSize: CGSize, parameters: ImageCroppingParameters?, previewImage: CGImage?) {
        self.originalImage = originalImage
        self.sourceSize = sourceSize
        self.croppingParameters = parameters
        self.previewImage = previewImage
    }
    
    // MARK: - ImageSource
    
    func requestImage<T : InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: ImageRequestResult<T> -> ())
        -> ImageRequestId
    {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
        let requestId = ImageRequestId(0)
        
        if let previewImage = previewImage where options.deliveryMode == .Progressive {
            dispatch_to_main_queue {
                resultHandler(ImageRequestResult(image: T(CGImage: previewImage), degraded: true, requestId: requestId))
            }
        }
        
        getCroppedImage { cgImage in
            
            let resizedImage: CGImage?
            
            switch options.size {
            case .FitSize(let size):
                resizedImage = cgImage.flatMap { $0.resized(toFit: size) }
            case .FillSize(let size):
                resizedImage = cgImage.flatMap { $0.resized(toFill: size) }
            case .FullResolution:
                resizedImage = cgImage
            }
            
            dispatch_to_main_queue {
                resultHandler(ImageRequestResult(
                    image: resizedImage.flatMap { T(CGImage: $0) },
                    degraded: false,
                    requestId: requestId
                ))
            }
        }
        
        return requestId
    }
    
    func cancelRequest(requestID: ImageRequestId) {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
    }
    
    func imageSize(completion: CGSize? -> ()) {
        getCroppedImage { cgImage in
            completion(cgImage.flatMap { CGSize(width: CGImageGetWidth($0), height: CGImageGetHeight($0)) })
        }
    }
    
    func fullResolutionImageData(completion: NSData? -> ()) {
        dispatch_async(processingQueue) {
            
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
    
    func isEqualTo(other: ImageSource) -> Bool {
        if let other = other as? CroppedImageSource {
            return originalImage.isEqualTo(other.originalImage) // TODO: сравнить croppingParameters
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private let croppedImageCache = SingleObjectCache<CGImageWrapper>()
    private let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
    
    private let processingQueue = dispatch_queue_create(
        "ru.avito.AvitoMediaPicker.CroppedImageSource.processingQueue",
        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0)
    )
    
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
        
        let options = ImageRequestOptions(size: .FitSize(sourceSize), deliveryMode: .Best)
        
        originalImage.requestImage(options: options) {
            [weak self, processingQueue] (result: ImageRequestResult<CGImageWrapper>) in
            
            dispatch_async(processingQueue) {
                if let originalCGImage = result.image?.image, croppingParameters = self?.croppingParameters {
                    self?.croppedImage = self?.newTransformedImage(originalCGImage, parameters: croppingParameters)
                }
                dispatch_async(dispatch_get_main_queue(), completion)
            }
        }
    }
    
    private func newTransformedImage(sourceImage: CGImage, parameters: ImageCroppingParameters) -> CGImage? {
        
        guard let source = newScaledImage(
            sourceImage,
            withOrientation: parameters.sourceOrientation,
            toSize: parameters.sourceSize,
            withQuality: .None
        ) else {
            return nil
        }
        
        let cropSize = parameters.cropSize
        let outputWidth = parameters.outputWidth
        let transform = parameters.transform
        let imageViewSize = parameters.imageViewSize
        
        let aspect = cropSize.height / cropSize.width
        let outputSize = CGSize(width: outputWidth, height: outputWidth * aspect)
        
        guard let colorSpace = CGImageGetColorSpace(source) else {
            return nil
        }
        
        guard let context = CGBitmapContextCreate(
            nil,
            Int(outputSize.width),
            Int(outputSize.height),
            CGImageGetBitsPerComponent(source),
            0,
            colorSpace,
            CGImageGetBitmapInfo(source).rawValue
        ) else {
            return nil
        }
        
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
