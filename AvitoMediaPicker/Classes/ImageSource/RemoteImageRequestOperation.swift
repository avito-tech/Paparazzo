final class RemoteImageRequestOperation<T: InitializableWithCGImage>: Operation, ImageRequestIdentifiable {
    
    let id: ImageRequestId
    
    init(id: ImageRequestId,
         url: URL,
         options: ImageRequestOptions,
         resultHandler: @escaping (ImageRequestResult<T>) -> (),
         callbackQueue: DispatchQueue = .main,
         imageDownloader: ImageDownloader)
    {
        self.id = id
        self.url = url
        self.options = options
        self.resultHandler = resultHandler
        self.callbackQueue = callbackQueue
        self.imageDownloader = imageDownloader
        
        super.init()
    }
    
    // MARK: - NSOperation
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        syncQueue.async {
            
            if self.isCancelled {
                self.isFinished = true
                return
            }
            
            self.isExecuting = true
            
            self.imageLoadingOperation = self.imageDownloader.downloadImageAtUrl(
                self.url,
                progressHandler: { receivedSize, expectedSize in
                    if let onDownloadStart = self.options.onDownloadStart, !self.downloadStarted {
                        self.callbackQueue.async { [imageRequestId = self.id] in
                            onDownloadStart(imageRequestId)
                        }
                        self.downloadStarted = true
                    }
                },
                completion: { image, _ in
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        let cgImage = image.flatMap { self.finalCGImage(from: $0) }
                        
                        self.callbackQueue.async { [imageRequestId = self.id] in
                            self.options.onDownloadFinish?(imageRequestId)
                            self.resultHandler(ImageRequestResult(
                                image: cgImage.flatMap { T(cgImage: $0) },
                                degraded: false,
                                requestId: imageRequestId
                            ))
                        }
                        
                        self.syncQueue.async {
                            self.finish()
                        }
                    }
                }
            )
        }
    }
    
    override func cancel() {
        syncQueue.async {
            guard !self.isFinished else { return }
            
            super.cancel()
            
            if self.isExecuting {
                
                self.imageLoadingOperation?.cancel()
                
                // SDWebImageDownloaderOperation will not call its completion block after cancellation,
                // so we need to call onDownloadFinish here
                if let onDownloadFinish = self.options.onDownloadFinish, self.downloadStarted {
                    self.callbackQueue.async { [imageRequestId = self.id] in
                        onDownloadFinish(imageRequestId)
                    }
                }
                
                self.finish()
            }
        }
    }
    
    // MARK: - Private
    
    private let url: URL
    private let options: ImageRequestOptions
    private let resultHandler: (ImageRequestResult<T>) -> ()
    private let callbackQueue: DispatchQueue
    
    private let imageDownloader: ImageDownloader
    private weak var imageLoadingOperation: CancellableImageDownload?
    private var downloadStarted = false
    private let syncQueue = DispatchQueue(label: "ru.avito.RemoteImageRequestOperation.syncQueue")
    private var _executing = false
    private var _finished = false
    
    private func finalCGImage(from image: CGImage) -> CGImage? {
        switch options.size {
        case .fullResolution:
            return image
        case .fillSize(let size):
            return image.resized(toFill: size)
        case .fitSize(let size):
            return image.resized(toFit: size)
        }
    }
    
    private func finish() {
        isExecuting = false
        isFinished = true
    }
}
