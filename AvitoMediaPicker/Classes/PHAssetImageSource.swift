import Photos

final class PHAssetImageSource: ImageSource {

    private let asset: PHAsset
    private let imageManager: PHImageManager
    
    private var thumbnailRequestId: PHImageRequestID?

    init(asset: PHAsset, imageManager: PHImageManager = PHImageManager.defaultManager()) {
        self.asset = asset
        self.imageManager = imageManager
    }

    // MARK: - AbstractImage
    
    func writeImageToUrl(url: NSURL, completion: Bool -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        
        imageManager.requestImageDataForAsset(asset, options: options) { data, uti, orientation, info in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [url] in
            
                var success = false
                
                let source = data.flatMap { CGImageSourceCreateWithData($0, nil) }
                let destination = uti.flatMap { CGImageDestinationCreateWithURL(url, $0, 1, nil) }
                
                if let source = source, destination = destination {
                    // TODO: может, надо юзать `CGImageDestinationAddImageAndMetadata`? Как создать `CGImageMetadata` из словаря `info`?
                    CGImageDestinationAddImageFromSource(destination, source, 0, nil)
                    success = CGImageDestinationFinalize(destination)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(success)
                }
            }
        }
    }

    func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ()) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat

        imageManager.requestImageDataForAsset(asset, options: options) { data, uti, orientation, info in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                let source = data.flatMap { CGImageSourceCreateWithData($0, nil) }
                let cgImage = source.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }

                dispatch_async(dispatch_get_main_queue()) {
                    completion(cgImage.flatMap { T(CGImage: $0) })
                }
            }
        }
    }

    func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, contentMode: ImageContentMode, completion: T? -> ()) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .Opportunistic

        let contentMode = PHImageContentMode(abstractImageContentMode: contentMode)
        
        if let thumbnailRequestId = thumbnailRequestId {
            imageManager.cancelImageRequest(thumbnailRequestId)
        }

        thumbnailRequestId = imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: options) { [weak self] image, _ in
            self?.thumbnailRequestId = nil
            completion(image?.CGImage.flatMap { T(CGImage: $0) })
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