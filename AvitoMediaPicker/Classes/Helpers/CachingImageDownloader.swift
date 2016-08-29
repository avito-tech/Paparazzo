protocol ImageDownloader {
    func downloadImageAtUrl(
        url: NSURL,
        progressHandler: ((receivedSize: Int, expectedSize: Int) -> ())?,
        completion: (image: CGImage?, error: NSError?) -> ()
    ) -> CancellableImageDownload
}

protocol CachingImageDownloader: ImageDownloader {
    func cachedImageForUrl(_: NSURL) -> CGImage?
}

protocol CancellableImageDownload: class {
    func cancel()
}