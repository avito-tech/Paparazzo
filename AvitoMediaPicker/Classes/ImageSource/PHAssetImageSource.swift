import Photos

final class PHAssetImageSource: ImageSource {

    private let asset: PHAsset
    private let imageManager: PHImageManager

    init(asset: PHAsset, imageManager: PHImageManager = PHImageManager.default()) {
        self.asset = asset
        self.imageManager = imageManager
    }

    // MARK: - AbstractImage
    
    func fullResolutionImageData(completion: @escaping (Data?) -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImageData(for: asset, options: options) { data, _, _, _ in
            completion(data)
        }
    }
    
    func imageSize(completion: @escaping (CGSize?) -> ()) {
        dispatch_to_main_queue {
            completion(CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight))
        }
    }
    
    func requestImage<T : InitializableWithCGImage>(
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
            let imageRequestId = info?[PHImageResultRequestIDKey] as? Int32 ?? 0
            
            if !downloadStarted {
                startDownload(imageRequestId)
            }
            if progress == 1 /* это не reliable, читай ниже */ && !downloadFinished {
                finishDownload(imageRequestId)
            }
        }

        return imageManager.requestImage(for: asset, targetSize: size, contentMode: contentMode, options: phOptions) { [weak self] image, info in
            
            let requestId = info?[PHImageResultRequestIDKey] as? Int32 ?? 0
            let degraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            let cancelled = info?[PHImageCancelledKey] as? Bool ?? false || self?.cancelledRequestIds.contains(requestId) == true
            let isLikelyToBeTheLastCallback = (image != nil && !degraded) || cancelled
            
            // progressHandler может никогда не вызваться с progress == 1, поэтому тут пытаемся угадать, завершилась ли загрузка
            if downloadStarted && !downloadFinished && isLikelyToBeTheLastCallback {
                finishDownload(requestId)
            }
            
            // resultHandler не должен вызываться после отмены запроса
            if !cancelled {
                if let image = image as? T? {
                    resultHandler(ImageRequestResult(image: image, degraded: degraded, requestId: requestId))
                } else {
                    resultHandler(ImageRequestResult(
                        image: image?.cgImage.flatMap { T(CGImage: $0) },
                        degraded: degraded,
                        requestId: requestId
                    ))
                }
            }
        }
    }
    
    func cancelRequest(_ id: ImageRequestId) {
        dispatch_to_main_queue {
            self.cancelledRequestIds.insert(id)
            self.imageManager.cancelImageRequest(id)
        }
    }
    
    func isEqualTo(_ other: ImageSource) -> Bool {
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
        case .Progressive:
            phOptions.deliveryMode = .opportunistic
            phOptions.resizeMode = .fast
        case .Best:
            phOptions.deliveryMode = .highQualityFormat
            phOptions.resizeMode = .exact
        }
        
        let size: CGSize
        let contentMode: PHImageContentMode
        
        switch options.size {
        case .FullResolution:
            size = PHImageManagerMaximumSize
            contentMode = .aspectFill
        case .FitSize(let sizeToFit):
            size = sizeToFit
            contentMode = .aspectFit
        case .FillSize(let sizeToFill):
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
