import Foundation
import CoreGraphics

/// Предлагается как замена UIImage/NSImage.
/// Позволяет оптимизировать память и абстрагировать источник картинки.

// TODO: перенести в фреймворк с утилитами
public protocol ImageSource: class {
    
    func imageSize(completion: CGSize? -> ())
    
    func fullResolutionImage<T: InitializableWithCGImage>(deliveryMode _: ImageDeliveryMode, resultHandler: T? -> ())
    func fullResolutionImageData(completion: NSData? -> ())
    
    func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: ImageContentMode,
        deliveryMode: ImageDeliveryMode,
        resultHandler: T? -> ()
    ) -> ImageRequestID
    
    func cancelRequest(_: ImageRequestID)

    func isEqualTo(other: ImageSource) -> Bool
}

public typealias ImageRequestID = Int32

public protocol InitializableWithCGImage {
    // Если хотим совсем ни к чему не привязываться (отвязаться от Core Graphics),
    // нужно создать свою структуру, представляющую bitmap, а потом реализовать
    // для UIImage и NSImage конструкторы, позволяющие инициализировать их из этой структуры.
    init(CGImage: CGImage)
}

public func ==(lhs: ImageSource, rhs: ImageSource) -> Bool {
    return lhs.isEqualTo(rhs)
}

public enum ImageContentMode {
    case AspectFit
    case AspectFill
}

public enum ImageDeliveryMode {
    case Progressive    // completion может вызываться несколько раз, по мере получения картинки лучшего качества
    case Best           // completion вызовется только один раз, когда будет получена картинка наилучшего качества (или если картинку не удается получить)
}

public extension ImageSource {
    
    func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ()) {
        fullResolutionImage(deliveryMode: .Best, resultHandler: completion)
    }
    
    public func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, resultHandler: T? -> ()) -> ImageRequestID {
        return imageFittingSize(size, contentMode: .AspectFill, deliveryMode: .Progressive, resultHandler: resultHandler)
    }
}