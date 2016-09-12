import Photos

final class MemorySavingAssetImageSource: ImageSource {
    
    init(assetImageSource: PHAssetImageSource, fileManager: NSFileManager) {
        self.assetImageSource = assetImageSource
        self.fileManager = fileManager
        
        localImageSourcePromise.fulfill { completion in
            self.createLocalImageSource(from: assetImageSource, completion: completion)
        }
    }
    
    // MARK: - ImageSource
    
    func requestImage<T: InitializableWithCGImage>(
        options options: ImageRequestOptions,
        resultHandler: ImageRequestResult<T> -> ())
        -> ImageRequestId
    {
        let requestId = ImageRequestId(MemorySavingAssetImageSource.requestIdsGenerator.nextInt())
        
        localImageSourcePromise.onFulfill { imageSource in
            if let imageSource = imageSource {
                imageSource.requestImage(options: options) { result in
                    resultHandler(ImageRequestResult(image: result.image, degraded: result.degraded, requestId: requestId))
                }
            } else {
                resultHandler(ImageRequestResult<T>(image: nil, degraded: false, requestId: requestId))
            }
        }
        
        return requestId
    }
    
    func cancelRequest(_: ImageRequestId) {
        // TODO
    }
    
    func imageSize(completion: CGSize? -> ()) {
        assetImageSource.imageSize(completion)
    }
    
    func fullResolutionImageData(completion: NSData? -> ()) {
        localImageSourcePromise.onFulfill { imageSource in
            if let imageSource = imageSource {
                imageSource.fullResolutionImageData(completion)
            } else {
                completion(nil)
            }
        }
    }
    
    func isEqualTo(other: ImageSource) -> Bool {
        if let other = other as? PHAssetImageSource {
            return assetImageSource.isEqualTo(other)
        } else if let other = other as? MemorySavingAssetImageSource {
            return assetImageSource.isEqualTo(other.assetImageSource)
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private let fileManager: NSFileManager
    private let assetImageSource: PHAssetImageSource
    private let localImageSourcePromise = Promise<LocalImageSource?>()
    
    private static let requestIdsGenerator = ThreadSafeIntGenerator()
    
    private func createLocalImageSource(from assetImageSource: PHAssetImageSource, completion: (LocalImageSource?) -> ()) {
        
        let temporaryDirectory: NSString = NSTemporaryDirectory()
        let path = temporaryDirectory.stringByAppendingPathComponent(assetImageSource.asset.localIdentifier)
        
        assetImageSource.fullResolutionImageData { [fileManager] data in
            guard let data = data else { return completion(nil) }
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                
                let directory = (path as NSString).stringByDeletingLastPathComponent
                var isDirectory = ObjCBool(false)
                
                if !(fileManager.fileExistsAtPath(directory, isDirectory: &isDirectory) && isDirectory.boolValue) {
                    try? fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
                }
                
                if data.writeToFile(path, atomically: true) {
                    
                    let previewOptions = ImageRequestOptions(
                        size: .FitSize(UIScreen.mainScreen().bounds.size),
                        deliveryMode: .Best
                    )
                        
                    let previewSource = LocalImageSource(path: path)
                    
                    previewSource.requestImage(options: previewOptions) { (result: ImageRequestResult<CGImageWrapper>) in
                        completion(LocalImageSource(path: path, previewImage: result.image?.image))
                    }
                    
                } else {
                    completion(nil)
                }
            }
        }
    }
}