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
    
    func fullResolutionImage<T : InitializableWithCGImage>(deliveryMode deliveryMode: ImageDeliveryMode, resultHandler: T? -> ()) {
        imageFittingSize(PHImageManagerMaximumSize, contentMode: .AspectFill, deliveryMode: deliveryMode, resultHandler: resultHandler)
    }
    
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

    func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: ImageContentMode,
        deliveryMode: ImageDeliveryMode,
        resultHandler: T? -> ())
        -> ImageRequestID
    {
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            debugPrint("Loading photo from iCloud: \(Int(progress * 100))%")
        }
        
        switch deliveryMode {
        case .Progressive:
            options.deliveryMode = .Opportunistic
            options.resizeMode = .Fast
        case .Best:
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Exact
        }

        let contentMode = PHImageContentMode(abstractImageContentMode: contentMode)

//        let assetId = asset.localIdentifier ?? ""
//        debugPrint("\(assetId): request image fitting size \(size)")
        return imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: options) { [weak self] image, info in
//            if let image = image {
//                let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
//                debugPrint("\(assetId): image manager returned UIImage with size = \(size)")
//            }
            
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
    init(abstractImageContentMode: ImageContentMode) {
        switch abstractImageContentMode {
        case .AspectFit:
            self = .AspectFit
        case .AspectFill:
            self = .AspectFill
        }
    }
}