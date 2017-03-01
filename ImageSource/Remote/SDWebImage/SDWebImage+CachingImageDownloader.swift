import SDWebImage

extension SDWebImageManager: CachingImageDownloader {
    
    public func downloadImageAtUrl(
        _ url: URL,
        progressHandler: ((_ receivedSize: Int, _ expectedSize: Int) -> ())?,
        completion: @escaping (_ image: CGImage?, _ error: Error?) -> ())
        -> CancellableImageDownload
    {
        return SDCancellableImageDownloadAdapter(
            operation: downloadImage(with: url, options: [], progress: progressHandler) { image, error, _, _, _ in
                completion(image?.cgImage, error)
            }
        )
    }
    
    public func cachedImageForUrl(_ url: URL) -> CGImage? {
        if let key = cacheKey(for: url) {
            return (imageCache?.imageFromMemoryCache(forKey: key) ?? imageCache?.imageFromDiskCache(forKey: key))?.cgImage
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
