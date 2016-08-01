import Photos
import AvitoDesignKit

final class PHAssetImageSource: ImageSource {

    private let asset: PHAsset
    private let imageManager: PHImageManager
    
    private var thumbnailRequestId: PHImageRequestID?

    init(asset: PHAsset, imageManager: PHImageManager = PHImageManager.defaultManager()) {
        self.asset = asset
        self.imageManager = imageManager
    }

    // MARK: - AbstractImage

    func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ()) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat

        imageManager.requestImageDataForAsset(asset, options: options) { data, uti, orientation, info in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                let source = data.flatMap { CGImageSourceCreateWithData($0, nil) }
                let exifOrientation = orientation.exifOrientation
                let cgImage = source.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }?.imageFixedForOrientation(exifOrientation)

                dispatch_async(dispatch_get_main_queue()) {
                    completion(cgImage.flatMap { T(CGImage: $0) })
                }
            }
        }
    }
    
    func fullResolutionImageData(completion: NSData? -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        
        imageManager.requestImageDataForAsset(asset, options: options) { data, uti, orientation, info in
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

    func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat

        let contentMode = PHImageContentMode(abstractImageContentMode: contentMode)
        
        if let thumbnailRequestId = thumbnailRequestId {
            imageManager.cancelImageRequest(thumbnailRequestId)
        }

        thumbnailRequestId = imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: options) { [weak self] image, _ in
            self?.thumbnailRequestId = nil
            completion(image?.CGImage.flatMap { T(CGImage: $0) })
        }
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