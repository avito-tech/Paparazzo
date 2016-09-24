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
     — вызывается не более одного раза, если options.deliveryMode == .best
     - может вызываться несколько раз, если options.deliveryMode == .progressive
     - может вызваться синхронно до выхода из функции!
    */
    @discardableResult
    func requestImage<T: InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (ImageRequestResult<T>) -> ())
        -> ImageRequestId
    
    func cancelRequest(_: ImageRequestId)
    
    func imageSize(completion: @escaping (CGSize?) -> ())
    
    func fullResolutionImageData(completion: @escaping (Data?) -> ())

    func isEqualTo(_ other: ImageSource) -> Bool
}

public typealias ImageRequestId = Int32

public struct ImageRequestResult<T> {
    public let image: T?
    /// Indicates whether `image` is a low quality version of requested image (may be true if delivery mode is .progressive)
    public let degraded: Bool
    public let requestId: ImageRequestId
}

public struct ImageRequestOptions {
    
    public var size: ImageSizeOption = .fullResolution
    public var deliveryMode: ImageDeliveryMode = .best
    
    /// Called on main thread
    public var onDownloadStart: ((ImageRequestId) -> ())?
    /// Called on main thread
    public var onDownloadFinish: ((ImageRequestId) -> ())?
    
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
    init(cgImage: CGImage)
}

public func ==(lhs: ImageSource, rhs: ImageSource) -> Bool {
    return lhs.isEqualTo(rhs)
}

@available(*, deprecated, message: "Use ImageSizeOption instead (see ImageSource.requestImage(options:resultHandler:))")
public enum ImageContentMode {
    case aspectFit
    case aspectFill
}

public enum ImageSizeOption: Equatable {
    case fitSize(CGSize)
    case fillSize(CGSize)
    case fullResolution
}

public func ==(sizeOption1: ImageSizeOption, sizeOption2: ImageSizeOption) -> Bool {
    switch (sizeOption1, sizeOption1) {
    case (.fitSize(let size1), .fitSize(let size2)):
        return size1 == size2
    case (.fillSize(let size1), .fillSize(let size2)):
        return size1 == size2
    case (.fullResolution, .fullResolution):
        return true
    default:
        return false
    }
}

public enum ImageDeliveryMode {
    case progressive    // completion может вызываться несколько раз, по мере получения картинки лучшего качества
    case best           // completion вызовется только один раз, когда будет получена картинка наилучшего качества (или если картинку не удается получить)
}

public extension ImageSource {
    
    public func fullResolutionImage<T: InitializableWithCGImage>(_ completion: @escaping (T?) -> ()) {
        fullResolutionImage(deliveryMode: .best, resultHandler: completion)
    }
    
    public func imageFittingSize<T: InitializableWithCGImage>(_ size: CGSize, resultHandler: @escaping (T?) -> ()) -> ImageRequestId {
        return imageFittingSize(size, contentMode: .aspectFill, deliveryMode: .progressive, resultHandler: resultHandler)
    }
    
    public func fullResolutionImage<T: InitializableWithCGImage>(deliveryMode: ImageDeliveryMode, resultHandler: @escaping (T?) -> ()) {
    
        var options = ImageRequestOptions()
        options.size = .fullResolution
        options.deliveryMode = deliveryMode
        
        requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
    
    public func requestImage<T: InitializableWithCGImage>(
        options: ImageRequestOptions,
        resultHandler: @escaping (T?) -> ())
        -> ImageRequestId
    {
        return requestImage(options: options) { (result: ImageRequestResult<T>) in
            resultHandler(result.image)
        }
    }
    
    @available(*, deprecated, message: "Use ImageSource.requestImage(options:resultHandler:) instead")
    public func imageFittingSize<T: InitializableWithCGImage>(
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
