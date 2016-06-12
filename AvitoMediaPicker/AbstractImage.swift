import CoreGraphics

protocol AbstractImage {
    
    func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ())
    
    func imageFittingSize<T: InitializableWithCGImage>(
        size: CGSize,
        contentMode: AbstractImageContentMode,
        completion: T? -> ()
    )
}

protocol InitializableWithCGImage {
    init(CGImage: CGImage)
}

enum AbstractImageContentMode {
    case AspectFit
    case AspectFill
}

extension AbstractImage {
    func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, completion: T? -> ()) {
        imageFittingSize(size, contentMode: .AspectFill, completion: completion)
    }
}