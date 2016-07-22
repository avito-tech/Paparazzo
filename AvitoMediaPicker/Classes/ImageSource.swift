import CoreGraphics

/// Предлагается как замена UIImage/NSImage.
/// Позволяет оптимизировать память и абстрагировать источник картинки.
public protocol ImageSource {
    
    func writeImageToUrl(url: NSURL, completion: Bool -> ())
    
    func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ())
    func imageSize(completion: CGSize? -> ())
    
    func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: ImageContentMode,
        completion: T? -> ()
    )
}

public protocol InitializableWithCGImage {
    // Если хотим совсем ни к чему не привязываться (отвязаться от Core Graphics),
    // нужно создать свою структуру, представляющую bitmap, а потом реализовать
    // для UIImage и NSImage конструкторы, позволяющие инициализировать их из этой структуры.
    init(CGImage: CGImage)
}

public enum ImageContentMode {
    case AspectFit
    case AspectFill
}

public extension ImageSource {
    public func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, completion: T? -> ()) {
        imageFittingSize(size, contentMode: .AspectFill, completion: completion)
    }
}