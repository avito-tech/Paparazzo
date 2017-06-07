import SDWebImage

public extension RemoteImageSource {
    public convenience init(url: URL, previewImage: CGImage? = nil) {
        self.init(url: url, previewImage: previewImage, imageDownloader: SDWebImageManager.shared())
    }
}
