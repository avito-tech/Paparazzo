public enum ImageDeliveryMode {
    /// `resultHandler` may be called multiple times providing a better quality image each time
    case progressive
    /// `resultHandler` will be called only once providing the best possible quality image (or not image if loading fails)
    case best
}
