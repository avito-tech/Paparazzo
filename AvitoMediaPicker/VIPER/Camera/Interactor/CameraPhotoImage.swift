import UIKit

struct CameraPhotoImage: LazyImage {

    private let photo: CameraPhoto
    private let imageResizingService: ImageResizingService
    
    init(photo: CameraPhoto, imageResizingService: ImageResizingService) {
        self.photo = photo
        self.imageResizingService = imageResizingService
    }

    // MARK: - LazyImage

    func fullResolutionImage<T:InitializableWithCGImage>(completion: (T?) -> ()) {
        if let path = photo.url.path, image = UIImage(contentsOfFile: path) {
            completion(image.CGImage.flatMap { T(CGImage: $0) })
        } else {
            completion(nil)
        }
    }

    func imageFittingSize<T:InitializableWithCGImage>(size: CGSize, contentMode: AbstractImageContentMode, completion: (T?) -> ()) {
        // TODO: actually resize image
        if let path = photo.thumbnailUrl.path, image = UIImage(contentsOfFile: path) {
            completion(image.CGImage.flatMap { T(CGImage: $0) })
        } else {
            completion(nil)
        }
    }
}
