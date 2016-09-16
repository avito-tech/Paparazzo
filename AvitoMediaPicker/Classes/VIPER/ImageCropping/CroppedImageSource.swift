import CoreGraphics
import ImageIO
import MobileCoreServices

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
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
        let requestId = ImageRequestId(0)
        
        if let previewImage = previewImage, options.deliveryMode == .Progressive {
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
    
    func cancelRequest(_ requestID: ImageRequestId) {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
    }
    
    func imageSize(completion: @escaping (CGSize?) -> ()) {
        getCroppedImage { cgImage in
            completion(cgImage.flatMap { CGSize(width: $0.width, height: $0.height) })
        }
    }
    
    func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        processingQueue.async {
            
            let data = NSMutableData()
            let destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil)
            
            if let image = self.croppedImage, let destination = destination {
                CGImageDestinationAddImage(destination, image, nil)
                CGImageDestinationFinalize(destination)
            }
            
            DispatchQueue.main.async {
                completion(data.length > 0 ? data as Data : nil)
            }
        }
    }
    
    func isEqualTo(_ other: ImageSource) -> Bool {
        if let other = other as? CroppedImageSource {
            return originalImage.isEqualTo(other.originalImage) // TODO: сравнить croppingParameters
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private let croppedImageCache = SingleObjectCache<CGImageWrapper>()
    private let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: false])
    
    private let processingQueue = DispatchQueue(
        label: "ru.avito.AvitoMediaPicker.CroppedImageSource.processingQueue",
        qos: .userInitiated,
        attributes: [.concurrent]
    )
    
    private var croppedImage: CGImage? {
        get { return croppedImageCache.value?.image }
        set { croppedImageCache.value = newValue.flatMap { CGImageWrapper(CGImage: $0) } }
    }
    
    private func getCroppedImage(completion: @escaping (CGImage?) -> ()) {
        if let croppedImage = croppedImage {
            completion(croppedImage)
        } else {
            performCrop { [weak self] in
                completion(self?.croppedImage)
            }
        }
    }
    
    private func performCrop(completion: @escaping () -> ()) {
        
        let options = ImageRequestOptions(size: .FitSize(sourceSize), deliveryMode: .Best)
        
        originalImage.requestImage(options: options) {
            [weak self, processingQueue] (result: ImageRequestResult<CGImageWrapper>) in
            
            processingQueue.async {
                if let originalCGImage = result.image?.image, let croppingParameters = self?.croppingParameters {
                    self?.croppedImage = self?.newTransformedImage(sourceImage: originalCGImage, parameters: croppingParameters)
                }
                DispatchQueue.main.async(execute: completion)
            }
        }
    }
    
    private func newTransformedImage(sourceImage: CGImage, parameters: ImageCroppingParameters) -> CGImage? {
        
        guard let source = newScaledImage(
            source: sourceImage,
            withOrientation: parameters.sourceOrientation,
            toSize: parameters.sourceSize,
            withQuality: .none
        ) else {
            return nil
        }
        
        let cropSize = parameters.cropSize
        let outputWidth = parameters.outputWidth
        let transform = parameters.transform
        let imageViewSize = parameters.imageViewSize
        
        let aspect = cropSize.height / cropSize.width
        let outputSize = CGSize(width: outputWidth, height: outputWidth * aspect)
        
        guard let colorSpace = source.colorSpace, let context = CGContext(
            data: nil,
            width: Int(outputSize.width),
            height: Int(outputSize.height),
            bitsPerComponent: source.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: source.bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: outputSize))
        
        var uiCoords = CGAffineTransform(
            scaleX: outputSize.width / cropSize.width,
            y: outputSize.height / cropSize.height
        )
        
        uiCoords = uiCoords.translatedBy(x: cropSize.width / 2, y: cropSize.height / 2)
        uiCoords = uiCoords.scaledBy(x: 1, y: -1)
        
        context.concatenate(uiCoords)
        context.concatenate(transform)
        context.scaleBy(x: 1, y: -1)
        
        context.draw(source, in: CGRect(
            x: -imageViewSize.width / 2,
            y: -imageViewSize.height / 2,
            width: imageViewSize.width,
            height: imageViewSize.height
        ))
        
        return context.makeImage()
    }
    
    private func newScaledImage(
        source: CGImage,
        withOrientation orientation: ExifOrientation,
        toSize size: CGSize,
        withQuality quality: CGInterpolationQuality
    ) -> CGImage? {
        
        let ciImage = CIImage(cgImage: source)
        
        let transform = CGAffineTransform.identity
            .translatedBy(x: size.width / 2, y: size.height / 2)
            .concatenating(ciImage.imageTransform(forOrientation: Int32(orientation.rawValue)))
            .translatedBy(x: -size.width / 2, y: -size.height / 2)
        
        return ciContext.createCGImage(
            ciImage.applying(transform),
            from: CGRect(origin: .zero, size: size)
        )
    }
}
