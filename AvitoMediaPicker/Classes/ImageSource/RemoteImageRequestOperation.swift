import SDWebImage

final class RemoteImageRequestOperation<T: InitializableWithCGImage>: NSOperation, ImageRequestIdentifiable {
    
    let id: ImageRequestId
    
    init(id: ImageRequestId,
         url: NSURL,
         options: ImageRequestOptions,
         resultHandler: ImageRequestResult<T> -> (),
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
    
    override var asynchronous: Bool {
        return true
    }
    
    override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    override func start() {
        dispatch_async(syncQueue) { 
            
            if self.cancelled {
                self.finished = true
                return
            }
            
            self.executing = true
            
            self.imageLoadingOperation = self.imageManager.downloadImageWithURL(
                self.url,
                options: SDWebImageOptions(),
                progress: { receivedSize, expectedSize in
//                debugPrint("\(url.lastPathComponent) downloaded \(Int(Float(receivedSize) / Float(expectedSize) * 100))%")
                    if let onDownloadStart = self.options.onDownloadStart where !self.downloadStarted {
                        dispatch_async(self.callbackQueue) { [imageRequestId = self.id] in
                            onDownloadStart(imageRequestId)
                        }
                        self.downloadStarted = true
                    }
                },
                completed: { image, error, cacheType, finished, url in
//                    debugPrint("imageLoadingOperation completed")
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        let cgImage = (image as UIImage?).flatMap { self.finalCGImage(from: $0) }
//                        debugPrint("requested size = \(self.options.size), imageSize = (\(CGImageGetWidth(cgImage)), \(CGImageGetHeight(cgImage)))")
                        
                        dispatch_async(self.callbackQueue) { [imageRequestId = self.id] in
                            self.options.onDownloadFinish?(imageRequestId)
                            self.resultHandler(ImageRequestResult(
                                image: cgImage.flatMap { T(CGImage: $0) },
                                degraded: false,
                                requestId: imageRequestId
                            ))
                        }
                        
                        dispatch_async(self.syncQueue) {
                            self.finish()
                        }
                    }
                }
            )
        }
    }
    
    override func cancel() {
        dispatch_async(syncQueue) {
            guard !self.finished else { return }
            
            super.cancel()
            
            if self.executing {
                
                self.imageLoadingOperation?.cancel()
                
                // SDWebImageDownloaderOperation will not call its completion block after cancellation,
                // so we need to call onDownloadFinish here
                if let onDownloadFinish = self.options.onDownloadFinish where self.downloadStarted {
                    dispatch_async(self.callbackQueue) { [imageRequestId = self.id] in
                        onDownloadFinish(imageRequestId)
                    }
                }
                
                self.finish()
            }
        }
    }
    
    // MARK: - Private
    
    private let url: NSURL
    private let options: ImageRequestOptions
    private let resultHandler: ImageRequestResult<T> -> ()
    private let callbackQueue: dispatch_queue_t
    
    private let imageManager = SDWebImageManager.sharedManager()
    private weak var imageLoadingOperation: SDWebImageOperation?
    private var downloadStarted = false
    
    private let syncQueue = dispatch_queue_create("ru.avito.RemoteImageRequestOperation.syncQueue", DISPATCH_QUEUE_SERIAL)
    private var _executing = false
    private var _finished = false
    
    private func finalCGImage(from image: UIImage) -> CGImage? {
        switch options.size {
        case .FullResolution:
            return image.CGImage
        case .FillSize(let size):
            return image.resized(toFill: size)?.CGImage
        case .FitSize(let size):
            return image.resized(toFit: size)?.CGImage
        }
    }
    
    private func finish() {
        executing = false
        finished = true
    }
}