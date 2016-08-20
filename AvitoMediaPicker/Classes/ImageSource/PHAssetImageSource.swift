import Photos
import AvitoDesignKit

final class PHAssetImageSource: ImageSource {

    private let asset: PHAsset
    private let imageManager: PHImageManager

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
            dispatch_async(dispatch_get_main_queue()) {
                completion(data)
            }
        }
    }
    
    func imageSize(completion: CGSize? -> ()) {
        dispatch_async(dispatch_get_main_queue()) { 
            completion(CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight))
        }
    }
    
    func requestImage<T : InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: T? -> ())
        -> ImageRequestID
    {
        let (phOptions, size, contentMode) = imageRequestParameters(from: options)
        
        var downloadStarted = false
        var downloadFinished = false
        
        let startDownload = {
            downloadStarted = true
            options.onDownloadStart.flatMap { dispatch_async(dispatch_get_main_queue(), $0) }
        }
        
        let finishDownload = {
            downloadFinished = true
            options.onDownloadFinish.flatMap { dispatch_async(dispatch_get_main_queue(), $0) }
        }
        
        phOptions.progressHandler = { [asset] progress, _, _, _ in
            debugPrint("Asset \(asset.localIdentifier): loading from iCloud - \(Int(progress * 100))%")
            if !downloadStarted {
                startDownload()
            }
            if progress == 1 /* это не reliable, читай ниже */ && !downloadFinished {
                finishDownload()
            }
        }

        return imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: phOptions) { [weak self] image, info in
            
            let degraded = info?[PHImageResultIsDegradedKey]?.boolValue ?? false
            let cancelled = info?[PHImageCancelledKey]?.boolValue ?? false
            let isLikelyToBeTheLastCallback = (image != nil && !degraded) || cancelled
            
            // progressHandler может никогда не вызваться с progress == 1, поэтому тут пытаемся угадать, завершилась ли загрузка
            if downloadStarted && !downloadFinished && isLikelyToBeTheLastCallback {
                finishDownload()
            }
            
            if let image = image as? T? {
                resultHandler(image)
            } else {
                resultHandler(image?.CGImage.flatMap { T(CGImage: $0) })
            }
        }
    }
    
    func cancelRequest(id: ImageRequestID) {
        imageManager.cancelImageRequest(id)
    }
    
    func isEqualTo(other: ImageSource) -> Bool {
        if let other = other as? PHAssetImageSource {
            return other.asset == asset
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
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