import CoreGraphics
import UIKit
import Photos

protocol AbstractImage {
    func fullResolutionImage(completion: CGImage? -> ())
    func imageFittingSize(size: CGSize, contentMode: AbstractImageContentMode, completion: CGImage? -> ())
}

extension MediaPickerPhoto: AbstractImage {
    
    func fullResolutionImage(completion: UIImage? -> ()) {
        completion(url.path.flatMap { UIImage(contentsOfFile: $0) })
    }
    
    func imageFittingSize(size: CGSize, contentMode: AbstractImageContentMode, completion: UIImage? -> ()) {
        // TODO: resize image using ImageIO
    }
}

struct PhotoLibraryItem: AbstractImage {
    
    let asset: PHAsset
    let imageManager: PHImageManager
    
    func fullResolutionImage(completion: UIImage? -> ()) {
        imageManager.requestImageDataForAsset(asset, options: nil) { data, _, _, _ in
            completion(data.flatMap { UIImage(data: $0) })
        }
    }
    
    func imageFittingSize(size: CGSize, contentMode: AbstractImageContentMode, completion: UIImage? -> ()) {
        imageManager.requestImageForAsset(
            asset,
            targetSize: size,
            contentMode: PHImageContentMode(contentMode),
            options: nil
        ) { image, _ in
            completion(image)
        }
    }
}

private extension PHImageContentMode {
    init(_ abstractImageContentMode: AbstractImageContentMode) {
        switch abstractImageContentMode {
        case .AspectFit:
            self = .AspectFit
        case .AspectFill:
            self = .AspectFill
        }
    }
}