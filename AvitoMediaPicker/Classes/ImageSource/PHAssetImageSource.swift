import Photos
import AvitoDesignKit

final class PHAssetImageSource: ImageSource {

    let asset: PHAsset
    let imageManager: PHImageManager

    init(asset: PHAsset, imageManager: PHImageManager = PHImageManager.defaultManager()) {
        self.asset = asset
        self.imageManager = imageManager
    }

    // MARK: - AbstractImage
    
    func fullResolutionImageData(completion: NSData? -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        options.networkAccessAllowed = true
        
        imageManager.requestImageDataForAsset(asset, options: options) { data, _, _, _ in
            completion(data)
        }
    }
    
    func imageSize(completion: CGSize? -> ()) {
        dispatch_to_main_queue {
            completion(CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight))
        }
    }
    
    func requestImage<T : InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: ImageRequestResult<T> -> ())
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
            let imageRequestId = info?[PHImageResultRequestIDKey]?.intValue ?? 0
            
            if !downloadStarted {
                startDownload(imageRequestId)
            }
            if progress == 1 /* это не reliable, читай ниже */ && !downloadFinished {
                finishDownload(imageRequestId)
            }
        }
        
        return imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: phOptions) { [weak self] image, info in
            let requestId = info?[PHImageResultRequestIDKey]?.intValue ?? 0
            let degraded = info?[PHImageResultIsDegradedKey]?.boolValue ?? false
            let cancelled = info?[PHImageCancelledKey]?.boolValue ?? false || self?.cancelledRequestIds.contains(requestId) == true
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
                        image: image?.CGImage.flatMap { T(CGImage: $0) },
                        degraded: degraded,
                        requestId: requestId
                    ))
                }
            }
        }
    }
    
    func cancelRequest(id: ImageRequestId) {
        dispatch_to_main_queue {
            self.cancelledRequestIds.insert(id)
            self.imageManager.cancelImageRequest(id)
        }
    }
    
    func isEqualTo(other: ImageSource) -> Bool {
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
        phOptions.networkAccessAllowed = true
        
        switch options.deliveryMode {
        case .Progressive:
            phOptions.deliveryMode = .Opportunistic
            phOptions.resizeMode = .Fast
        case .Best:
            phOptions.deliveryMode = .HighQualityFormat
            phOptions.resizeMode = .Exact
        }
        
        let size: CGSize
        let contentMode: PHImageContentMode
        
        switch options.size {
        case .FullResolution:
            size = PHImageManagerMaximumSize
            contentMode = .AspectFill
        case .FitSize(let sizeToFit):
            size = sizeToFit
            contentMode = .AspectFit
        case .FillSize(let sizeToFill):
            size = sizeToFill
            contentMode = .AspectFill
        }
        
        return (options: phOptions, size: size, contentMode: contentMode)
    }
}

private extension PHImageContentMode {
    var debugDescription: String {
        switch self {
        case .AspectFit:
            return "AspectFit"
        case .AspectFill:
            return "AspectFill"
        }
    }
}