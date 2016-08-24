import Foundation
import CoreGraphics

/// Предлагается как замена UIImage/NSImage.
/// Позволяет оптимизировать память и абстрагировать источник картинки.

// TODO: перенести в фреймворк с утилитами
public protocol ImageSource: class {
    
    /*
     TODO: (ayutkin) проверить, чтобы логика вызова resultHandler для всех ImageSource была такой:
     — вызывается как минимум один раз, кроме случая отмены запроса
     - после отмены запроса не вызывается
     — вызывается не более одного раза, если options.deliveryMode == .Best
     - может вызываться несколько раз, если options.deliveryMode == .Progressive
    */
    func requestImage<T: InitializableWithCGImage>(
        options _: ImageRequestOptions,
        resultHandler: ImageRequestResult<T> -> ())
        -> ImageRequestId
    
    func cancelRequest(_: ImageRequestId)
    
    func imageSize(completion: CGSize? -> ())
    
    func fullResolutionImageData(completion: NSData? -> ())

    func isEqualTo(other: ImageSource) -> Bool
}

public typealias ImageRequestId = Int32

public struct ImageRequestResult<T> {
    let image: T?
    /// Indicates whether `image` is a low quality version of requested image (may be true if delivery mode is .Progressive)
    let degraded: Bool
    let requestId: ImageRequestId
}

public struct ImageRequestOptions {
    
    public var size: ImageSizeOption = .FullResolution
    public var deliveryMode: ImageDeliveryMode = .Best
    
    /// Called on main thread
    public var onDownloadStart: (ImageRequestId -> ())?
    /// Called on main thread
    public var onDownloadFinish: (ImageRequestId -> ())?
    
    public init() {}
    
    public init(size: ImageSizeOption, deliveryMode: ImageDeliveryMode) {
        self.size = size
        self.deliveryMode = deliveryMode
    }
}

public protocol InitializableWithCGImage {
    // Если хотим совсем ни к чему не привязываться (отвязаться от Core Graphics),
    // нужно создать свою структуру, представляющую bitmap, а потом реализовать
    // для UIImage и NSImage конструкторы, позволяющие инициализировать их из этой структуры.
    init(CGImage: CGImage)
}

public func ==(lhs: ImageSource, rhs: ImageSource) -> Bool {
    return lhs.isEqualTo(rhs)
}

@available(*, deprecated, message="Use ImageSizeOption instead (see ImageSource.requestImage(options:resultHandler:))")
public enum ImageContentMode {
    case AspectFit
    case AspectFill
}

public enum ImageSizeOption: Equatable {
    case FitSize(CGSize)
    case FillSize(CGSize)
    case FullResolution
}

public func ==(sizeOption1: ImageSizeOption, sizeOption2: ImageSizeOption) -> Bool {
    switch (sizeOption1, sizeOption1) {
    case (.FitSize(let size1), .FitSize(let size2)):
        return size1 == size2
    case (.FillSize(let size1), .FillSize(let size2)):
        return size1 == size2
    case (.FullResolution, .FullResolution):
        return true
    default:
        return false
    }
}

public enum ImageDeliveryMode {
    case Progressive    // completion может вызываться несколько раз, по мере получения картинки лучшего качества
    case Best           // completion вызовется только один раз, когда будет получена картинка наилучшего качества (или если картинку не удается получить)
}

public extension ImageSource {
    
    public func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ()) {
        fullResolutionImage(deliveryMode: .Best, resultHandler: completion)
    }
    
    public func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, resultHandler: T? -> ()) -> ImageRequestId {
        return imageFittingSize(size, contentMode: .AspectFill, deliveryMode: .Progressive, resultHandler: resultHandler)
    }
    
    public func fullResolutionImage<T: InitializableWithCGImage>(deliveryMode deliveryMode: ImageDeliveryMode, resultHandler: T? -> ()) {
    
        var options = ImageRequestOptions()
        options.size = .FullResolution
        options.deliveryMode = deliveryMode
        
        requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
    
    public func requestImage<T: InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: T? -> ())
        -> ImageRequestId
    {
        return requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
    
    @available(*, deprecated, message="Use ImageSource.requestImage(options:resultHandler:) instead")
    public func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: ImageContentMode,
        deliveryMode: ImageDeliveryMode,
        resultHandler: T? -> ())
        -> ImageRequestId
    {
        var options = ImageRequestOptions()
        options.deliveryMode = deliveryMode
        
        switch contentMode {
        case .AspectFit:
            options.size = .FitSize(size)
        case .AspectFill:
            options.size = .FillSize(size)
        }
        
        return requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
}