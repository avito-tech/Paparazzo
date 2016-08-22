import SDWebImage

final class RemoteImageRequestOperation<T: InitializableWithCGImage>: AsynchronousOperation, ImageRequestIdentifiable {
    
    let id: ImageRequestID
    
    init(id: ImageRequestID,
         url: NSURL,
         options: ImageRequestOptions,
         resultHandler: T? -> (),
         callbackQueue: dispatch_queue_t = dispatch_get_main_queue())
    {
        self.id = id
        self.url = url
        self.options = options
        self.resultHandler = resultHandler
        self.callbackQueue = callbackQueue
        
        super.init()
    }
    
    // MARK: - NSOperation
    
    override func main() {
        
        imageLoadingOperation = imageManager.downloadImageWithURL(
            url,
            options: SDWebImageOptions(),
            progress: { [weak self, callbackQueue, onDownloadStart = options.onDownloadStart] receivedSize, expectedSize in
                if let onDownloadStart = onDownloadStart where self?.downloadStarted == false {
                    dispatch_async(callbackQueue, onDownloadStart)
                    self?.downloadStarted = true
                }
            },
            completed: { [weak self, callbackQueue, resultHandler, onDownloadFinish = options.onDownloadFinish] image, error, cacheType, finished, url in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    
                    let cgImage = (image as UIImage?).flatMap { self?.finalCGImage(from: $0) }
                    debugPrint("requested size = \(self?.options.size), imageSize = (\(CGImageGetWidth(cgImage)), \(CGImageGetHeight(cgImage)))")
                    
                    dispatch_async(callbackQueue) {
                        onDownloadFinish?()
                        resultHandler(cgImage.flatMap { T(CGImage: $0) })
                    }
                    
                    self?.state = .Finished
                }
            }
        )
    }
    
    override func cancel() {
        super.cancel()
        
        imageLoadingOperation?.cancel()     // SDWebImageDownloaderOperation will not call its completion block after cancellation
        
        switch state {
        
        case .Executing:
            if let onDownloadFinish = options.onDownloadFinish where downloadStarted {
                dispatch_async(callbackQueue, onDownloadFinish)
            }
            
            state = .Finished
        
        case .Ready, .Finished:
            break
        }
    }
    
    // MARK: - Private
    
    private let url: NSURL
    private let options: ImageRequestOptions
    private let resultHandler: T? -> ()
    private let callbackQueue: dispatch_queue_t
    
    private let imageManager = SDWebImageManager.sharedManager()
    private var imageLoadingOperation: SDWebImageOperation?
    private var downloadStarted = false
    
    private func finalCGImage(from image: UIImage) -> CGImage? {
        switch options.size {
        case .FullResolution:
            return image.CGImage
        case .FillSize(let size):
            let scale = max(size.width / image.size.width, size.height / image.size.height)
            return image.resized(toFit: image.size.scaled(scale))?.CGImage
        case .FitSize(let size):
            let scale = min(size.width / image.size.width, size.height / image.size.height)
            return image.resized(toFit: image.size.scaled(scale))?.CGImage
        }
    }
}