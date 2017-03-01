import Photos

public final class PHAssetImageSource: ImageSource {

    private let asset: PHAsset
    private let imageManager: PHImageManager

    public init(asset: PHAsset, imageManager: PHImageManager = PHImageManager.default()) {
        self.asset = asset
        self.imageManager = imageManager
    }

    // MARK: - AbstractImage
    
    public func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImageData(for: asset, options: options) { data, _, _, _ in
            completion(data)
        }
    }
    
    public func imageSize(completion: @escaping (CGSize?) -> ()) {
        dispatch_to_main_queue {
            completion(CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight))
        }
    }
    
    @discardableResult
    public func requestImage<T : InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    {
        let (phOptions, size, contentMode) = imageRequestParameters(from: options)
        
        var downloadStarted = false
        var downloadFinished = false
        
        let startDownload = { (imageRequestId: ImageRequestId) in
            downloadStarted = true
            if let onDownloadStart = options.onDownloadStart {
                dispatch_to_main_queue { onDownloadStart(imageRequestId) }
            }
        }
        
        let finishDownload = { (imageRequestId: ImageRequestId) in
            downloadFinished = true
            if let onDownloadFinish = options.onDownloadFinish {
                dispatch_to_main_queue { onDownloadFinish(imageRequestId) }
            }
        }
        
        phOptions.progressHandler = { progress, _, _, info in
            let imageRequestId = (info?[PHImageResultRequestIDKey] as? NSNumber)?.int32Value ?? 0
            
            if !downloadStarted {
                startDownload(imageRequestId.toImageRequestId())
            }
            if progress == 1 /* это не reliable, читай ниже */ && !downloadFinished {
                finishDownload(imageRequestId.toImageRequestId())
            }
        }

        let id = imageManager.requestImage(for: asset, targetSize: size, contentMode: contentMode, options: phOptions) {
            [weak self] image, info in
            
            let requestId = (info?[PHImageResultRequestIDKey] as? NSNumber)?.int32Value ?? 0
            let degraded = (info?[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false
            let cancelled = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue ?? false || self?.cancelledRequestIds.contains(requestId.toImageRequestId()) == true
            let isLikelyToBeTheLastCallback = (image != nil && !degraded) || cancelled
            
            // progressHandler может никогда не вызваться с progress == 1, поэтому тут пытаемся угадать, завершилась ли загрузка
            if downloadStarted && !downloadFinished && isLikelyToBeTheLastCallback {
                finishDownload(requestId.toImageRequestId())
            }
            
            // resultHandler не должен вызываться после отмены запроса
            if !cancelled {
                resultHandler(ImageRequestResult(
                    image: (image as? T?).flatMap { $0 } ?? image?.cgImage.flatMap { T(cgImage: $0) },
                    degraded: degraded,
                    requestId: requestId.toImageRequestId()
                ))
            }
        }
        
        return id.toImageRequestId()
    }
    
    public func cancelRequest(_ id: ImageRequestId) {
        dispatch_to_main_queue {
            self.cancelledRequestIds.insert(id)
            self.imageManager.cancelImageRequest(id.int32Value)
        }
    }
    
    public func isEqualTo(_ other: ImageSource) -> Bool {
        if other === self {
            return true
        } else if let other = other as? PHAssetImageSource {
            return other.asset.localIdentifier == asset.localIdentifier
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private var cancelledRequestIds = Set<ImageRequestId>()
    
    private func imageRequestParameters(from options: ImageRequestOptions)
        -> (options: PHImageRequestOptions, size: CGSize, contentMode: PHImageContentMode)
    {
        let phOptions = PHImageRequestOptions()
        phOptions.isNetworkAccessAllowed = true
        
        switch options.deliveryMode {
        case .progressive:
            phOptions.deliveryMode = .opportunistic
            phOptions.resizeMode = .fast
        case .best:
            phOptions.deliveryMode = .highQualityFormat
            phOptions.resizeMode = .exact
        }
        
        let size: CGSize
        let contentMode: PHImageContentMode
        
        switch options.size {
        case .fullResolution:
            size = PHImageManagerMaximumSize
            contentMode = .aspectFill
        case .fitSize(let sizeToFit):
            size = sizeToFit
            contentMode = .aspectFit
        case .fillSize(let sizeToFill):
            size = sizeToFill
            contentMode = .aspectFill
        }
        
        return (options: phOptions, size: size, contentMode: contentMode)
    }
}

private extension PHImageContentMode {
    var debugDescription: String {
        switch self {
        case .aspectFit:
            return "AspectFit"
        case .aspectFill:
            return "AspectFill"
        }
    }
}
