import CoreGraphics
import ImageIO
import ImageSource

final class CroppedImageSource: ImageSource {
    
    let originalImage: ImageSource
    let sourceSize: CGSize
    let croppingParameters: ImageCroppingParameters?
    let previewImage: CGImage?
    
    init(originalImage: ImageSource,
         sourceSize: CGSize,
         parameters: ImageCroppingParameters?,
         previewImage: CGImage?,
         imageStorage: ImageStorage)
    {
        self.originalImage = originalImage
        self.sourceSize = sourceSize
        self.croppingParameters = parameters
        self.previewImage = previewImage
        self.imageStorage = imageStorage
    }
    
    deinit {
        if let croppedImage = croppedImage {
            imageStorage.remove(croppedImage.path)
        }
    }
    
    // MARK: - ImageSource
    
    func requestImage<T: InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
        let requestId = ImageRequestId(hashable: 0)
        
        if let previewImage = previewImage, options.deliveryMode == .progressive {
            dispatch_to_main_queue {
                resultHandler(ImageRequestResult(image: T(cgImage: previewImage), degraded: true, requestId: requestId))
            }
        }
        
        getCroppedImage { croppedImageSource in
            if let croppedImageSource = croppedImageSource {
                croppedImageSource.requestImage(options: options, resultHandler: resultHandler)
            } else {
                resultHandler(ImageRequestResult<T>(image: nil, degraded: false, requestId: requestId))
            }
        }
        
        return requestId
    }
    
    func cancelRequest(_ requestID: ImageRequestId) {
        // TODO: надо будет как-нибудь на досуге сделать возможность отмены, но сейчас здесь это не критично
    }
    
    func imageSize(completion: @escaping (CGSize?) -> ()) {
        getCroppedImage { croppedImageSource in
            if let croppedImageSource = croppedImageSource {
                croppedImageSource.imageSize(completion: completion)
            } else {
                completion(nil)
            }
        }
    }
    
    func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        getCroppedImage { croppedImageSource in
            if let croppedImageSource = croppedImageSource {
                croppedImageSource.fullResolutionImageData(completion: completion)
            } else {
                completion(nil)
            }
        }
    }
    
    func isEqualTo(_ other: ImageSource) -> Bool {
        if let other = other as? CroppedImageSource {
            return originalImage.isEqualTo(other.originalImage) && croppingParameters == other.croppingParameters
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private let ciContext = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
    private let imageStorage: ImageStorage
    private var croppedImage: LocalImageSource?
    
    private let processingQueue = DispatchQueue(
        label: "ru.avito.AvitoMediaPicker.CroppedImageSource.processingQueue",
        qos: .userInitiated,
        attributes: [.concurrent]
    )
    
    private func getCroppedImage(completion: @escaping (ImageSource?) -> ()) {
        if let croppedImage = croppedImage {
            completion(croppedImage)
        } else {
            performCrop { [weak self] in
                completion(self?.croppedImage)
            }
        }
    }
    
    private func performCrop(completion: @escaping () -> ()) {
        let greatestFiniteMagnitudeSize = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let imageSizeOption: ImageSizeOption = (sourceSize == greatestFiniteMagnitudeSize)
            ? .fullResolution
            : .fitSize(sourceSize)
        
        let options = ImageRequestOptions(size: imageSizeOption, deliveryMode: .best)

        originalImage.requestImage(options: options) {
            [weak self, processingQueue] (result: ImageRequestResult<CGImageWrapper>) in
            
            processingQueue.async {
                
                if let originalCGImage = result.image?.image,
                   let croppingParameters = self?.croppingParameters,
                   let croppedCgImage = self?.newTransformedImage(sourceImage: originalCGImage, parameters: croppingParameters)
                {
                    if let path = self?.imageStorage.save(croppedCgImage) {
                        self?.croppedImage = LocalImageSource(
                            path: path,
                            previewImage: self?.previewImage
                        )
                    }
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
            .concatenating(ciImage.orientationTransform(forExifOrientation: Int32(orientation.rawValue)))
            .translatedBy(x: -size.width / 2, y: -size.height / 2)
        
        return ciContext.createCGImage(
            ciImage.transformed(by: transform),
            from: CGRect(origin: .zero, size: size)
        )
    }
}
