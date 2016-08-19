import Photos
import AvitoDesignKit

final class PHAssetImageSource: ImageSource {
    
    private let asset: PHAsset
    private let imageManager: PHImageManager
    
    private let requestIdGenerator = ThreadSafeIntGenerator()
    private var imageRequestIdsMap = ThreadSafeMap<ImageRequestID, PHImageRequestID>()

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
        let (phOptions, size, contentMode) = photoRequestParameters(from: options)
        
        let finalResultHandler = { (image: UIImage?, _: [NSObject : AnyObject]?) in
            if let image = image as? T? {
                resultHandler(image)
            } else {
                resultHandler(image?.CGImage.flatMap { T(CGImage: $0) })
            }
        }
        
//        debugPrint("requesting asset image: size = \(size), contentMode = \(contentMode.debugDescription)")

        let requestId = ImageRequestID(requestIdGenerator.nextInt())
        
        // Сначала пытаемся получить локальную фотку
        let phRequestId = imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: phOptions) { [weak self, imageManager, asset] image, info in
            
            let needToDownloadImageFromCloud = (image == nil && info?[PHImageResultIsInCloudKey]?.boolValue == true)
            
            if needToDownloadImageFromCloud {
                // Если локальной фотки нет, то уведомляем об этом клиентский код, модифицируем параметры запроса,
                // чтобы позволить Photos качать фото из сети и повторяем запрос
                
                options.onDownloadNeeded?()
                
                phOptions.networkAccessAllowed = true
                phOptions.progressHandler = { progress, _, _, _ in
                    debugPrint("Loading photo from iCloud: \(Int(progress * 100))%")
                    options.onDownloadProgressChange?(downloadProgress: Float(progress))
                }
                
                let phRequestId = imageManager.requestImageForAsset(
                    asset,
                    targetSize: size,
                    contentMode: contentMode,
                    options: phOptions,
                    resultHandler: finalResultHandler
                )
                
                self?.imageRequestIdsMap[requestId] = phRequestId
                
            } else {
                finalResultHandler(image, info)
            }
        }
        
        imageRequestIdsMap[requestId] = phRequestId
        
        return requestId
    }
    
    func cancelRequest(id: ImageRequestID) {
        if let phRequestId = imageRequestIdsMap[id] {
            imageManager.cancelImageRequest(phRequestId)
        }
    }
    
    func isEqualTo(other: ImageSource) -> Bool {
        if let other = other as? PHAssetImageSource {
            return other.asset == asset
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private func photoRequestParameters(from options: ImageRequestOptions)
        -> (options: PHImageRequestOptions, size: CGSize, contentMode: PHImageContentMode)
    {
        let phOptions = PHImageRequestOptions()
        
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