import Photos

struct PhotoLibraryAssetImage: LazyImage {

    private let asset: PHAsset
    private let imageManager: PHImageManager

    init(asset: PHAsset, imageManager: PHImageManager = PHImageManager.defaultManager()) {
        self.asset = asset
        self.imageManager = imageManager
    }

    // MARK: - AbstractImage

    func fullResolutionImage<T: InitializableWithCGImage>(completion: T? -> ()) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat

        imageManager.requestImageDataForAsset(asset, options: options) { data, uti, orientation, info in

            let dataProvider = CGDataProviderCreateWithCFData(data)

            let cgImage = CGImageCreateWithJPEGDataProvider(
            dataProvider,
                UnsafePointer<CGFloat>(nil),
                false,
                .RenderingIntentDefault
            )

            completion(cgImage.flatMap { T(CGImage: $0) })
        }
    }

    func imageFittingSize<T: InitializableWithCGImage>(size: CGSize, contentMode: AbstractImageContentMode, completion: T? -> ()) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .Opportunistic

        let contentMode = PHImageContentMode(abstractImageContentMode: contentMode)

        imageManager.requestImageForAsset(asset, targetSize: size, contentMode: contentMode, options: options) { image, _ in
            completion(image?.CGImage.flatMap { T(CGImage: $0) })
        }
    }
}

private extension PHImageContentMode {
    init(abstractImageContentMode: AbstractImageContentMode) {
        switch abstractImageContentMode {
        case .AspectFit:
            self = .AspectFit
        case .AspectFill:
            self = .AspectFill
        }
    }
}