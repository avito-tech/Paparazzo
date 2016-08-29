import SDWebImage

extension SDWebImageManager: CachingImageDownloader {
    
    func downloadImageAtUrl(
        url: NSURL,
        progressHandler: ((receivedSize: Int, expectedSize: Int) -> ())?,
        completion: (image: CGImage?, error: NSError?) -> ())
        -> CancellableImageDownload
    {
        return SDCancellableImageDownloadAdapter(
            operation: downloadImageWithURL(url, options: SDWebImageOptions(), progress: progressHandler) { image, error, _, _, _ in
                completion(image: image?.CGImage, error: error)
            }
        )
    }
    
    func cachedImageForUrl(url: NSURL) -> CGImage? {
        if let key = cacheKeyForURL(url) {
            return (imageCache?.imageFromMemoryCacheForKey(key) ?? imageCache?.imageFromDiskCacheForKey(key))?.CGImage
        } else {
            return nil
        }
    }
}

final class SDCancellableImageDownloadAdapter: CancellableImageDownload {
    
    let operation: SDWebImageOperation
    
    init(operation: SDWebImageOperation) {
        self.operation = operation
    }
    
    func cancel() {
        operation.cancel()
    }
}