import SDWebImage

public extension RemoteImageSource {
    public convenience init(url: NSURL, previewImage: CGImage? = nil) {
        self.init(url: url, previewImage: previewImage, imageDownloader: SDWebImageManager.sharedManager())
    }
}