public protocol ImageDownloader {
    func downloadImageAtUrl(
        _: URL,
        progressHandler: ((_ receivedSize: Int64, _ expectedSize: Int64) -> ())?,
        completion: @escaping (_ image: CGImage?, _ error: Error?) -> ()
    ) -> CancellableImageDownload
}

public protocol CachingImageDownloader: ImageDownloader {
    func cachedImageForUrl(_: URL) -> CGImage?
}

public protocol CancellableImageDownload: class {
    func cancel()
}
