import ImageSource

public extension ImageSource {
    
    func fullResolutionImage<T: InitializableWithCGImage>(_ completion: @escaping (T?) -> ()) {
        fullResolutionImage(deliveryMode: .best, resultHandler: completion)
    }
    
    @discardableResult
    func imageFittingSize<T: InitializableWithCGImage>(_ size: CGSize, resultHandler: @escaping (T?) -> ()) -> ImageRequestId {
        return imageFittingSize(size, contentMode: .aspectFill, deliveryMode: .progressive, resultHandler: resultHandler)
    }
    
    func fullResolutionImage<T: InitializableWithCGImage>(deliveryMode: ImageDeliveryMode, resultHandler: @escaping (T?) -> ()) {
        
        var options = ImageRequestOptions()
        options.size = .fullResolution
        options.deliveryMode = deliveryMode
        
        requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
    
    @discardableResult
    func requestImage<T: InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (T?) -> ())
        -> ImageRequestId
    {
        return requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
    
    @available(*, deprecated, message: "Use ImageSource.requestImage(options:resultHandler:) instead")
    @discardableResult
    func imageFittingSize<T: InitializableWithCGImage>(
        _ size: CGSize,
        contentMode: ImageContentMode,
        deliveryMode: ImageDeliveryMode,
        resultHandler: @escaping (T?) -> ())
        -> ImageRequestId
    {
        var options = ImageRequestOptions()
        options.deliveryMode = deliveryMode
        
        switch contentMode {
        case .aspectFit:
            options.size = .fitSize(size)
        case .aspectFill:
            options.size = .fillSize(size)
        }
        
        return requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
}

@available(*, deprecated, message: "Use ImageSizeOption instead (see ImageSource.requestImage(options:resultHandler:))")
public enum ImageContentMode {
    case aspectFit
    case aspectFill
}
