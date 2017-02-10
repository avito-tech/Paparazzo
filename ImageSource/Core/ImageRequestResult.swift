public struct ImageRequestResult<T> {
    
    public let image: T?
    /// Indicates whether `image` is a low quality version of requested image (may be true if delivery mode is .progressive)
    public let degraded: Bool
    public let requestId: ImageRequestId
    
    public init(image: T?, degraded: Bool, requestId: ImageRequestId) {
        self.image = image
        self.degraded = degraded
        self.requestId = requestId
    }
}
