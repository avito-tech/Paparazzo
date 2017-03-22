public struct ImageRequestOptions {
    
    public var size: ImageSizeOption = .fullResolution
    public var deliveryMode: ImageDeliveryMode = .best
    
    /// Called on main thread when image download starts
    public var onDownloadStart: ((ImageRequestId) -> ())?
    /// Called on main thread when image download finishes
    public var onDownloadFinish: ((ImageRequestId) -> ())?
    
    public init() {}
    
    public init(size: ImageSizeOption, deliveryMode: ImageDeliveryMode) {
        self.size = size
        self.deliveryMode = deliveryMode
    }
}
