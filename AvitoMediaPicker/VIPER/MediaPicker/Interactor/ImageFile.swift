import Foundation
import ImageIO

struct ImageFile: LazyImage {

    private let url: NSURL
    private let imageResizingService: ImageResizingService
    
    init?(fileUrl url: NSURL, imageResizingService: ImageResizingService) {
        // Ну вы держитесь тут, со Swift 3 придет и нормальное название метода `fileURL` (`isFileURL`)
        guard url.fileURL else { return nil }
        
        self.url = url
        self.imageResizingService = imageResizingService
    }

    // MARK: - LazyImage

    func fullResolutionImage<T: InitializableWithCGImage>(completion: (T?) -> ()) {
        
        let source = CGImageSourceCreateWithURL(url, nil)
        
        completion(source.flatMap { source in
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
            return cgImage.flatMap { T(CGImage: $0) }
        })
    }

    func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, contentMode: LazyImageContentMode, completion: (T?) -> ()) {
        if let path = url.path {
            imageResizingService.resizeImage(atPath: path, toPixelSize: size) { cgImage in
                completion(cgImage.flatMap { T(CGImage: $0) })
            }
        } else {
            completion(nil)
        }
    }
}
