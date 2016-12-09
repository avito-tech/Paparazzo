protocol ImageDownloader {
    func downloadImageAtUrl(
        _: URL,
        progressHandler: ((_ receivedSize: Int, _ expectedSize: Int) -> ())?,
        completion: @escaping (_ image: CGImage?, _ error: Error?) -> ()
    ) -> CancellableImageDownload
}

protocol CachingImageDownloader: ImageDownloader {
    func cachedImageForUrl(_: URL) -> CGImage?
}

protocol CancellableImageDownload: class {
    func cancel()
}
