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
        let phOptions = PHImageRequestOptions()
        phOptions.networkAccessAllowed = true
        phOptions.progressHandler = { progress, _, _, _ in
            debugPrint("Loading photo from iCloud: \(Int(progress * 100))%")
            options.onDownloadProgressChange?(downloadProgress: Float(progress))
        }
        
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
        
        debugPrint("requesting asset image: size = \(size), contentMode = \(contentMode.debugDescription)")

        return imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: phOptions) { [weak self] image, info in
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