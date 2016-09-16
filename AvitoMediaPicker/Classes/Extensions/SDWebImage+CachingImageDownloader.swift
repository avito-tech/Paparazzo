import SDWebImage

extension SDWebImageManager: CachingImageDownloader {
    
    func downloadImageAtUrl(
        _ url: URL,
        progressHandler: ((_ receivedSize: Int, _ expectedSize: Int) -> ())?,
        completion: @escaping (_ image: CGImage?, _ error: NSError?) -> ())
        -> CancellableImageDownload
    {
        return SDCancellableImageDownloadAdapter(
            operation: downloadImageWithURL(url, options: SDWebImageOptions(), progress: progressHandler) { image, error, _, _, _ in
                completion(image?.CGImage, error)
            }
        )
    }
    
    func cachedImageForUrl(url: URL) -> CGImage? {
        if let key = cacheKey(for: url) {
            return (imageCache?.imageFromMemoryCacheForKey(key) ?? imageCache?.imageFromDiskCacheForKey(key))?.cgImage
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
