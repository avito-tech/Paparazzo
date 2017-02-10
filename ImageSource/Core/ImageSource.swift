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

public func ==(lhs: ImageSource, rhs: ImageSource) -> Bool {
    return lhs.isEqualTo(rhs)
}
