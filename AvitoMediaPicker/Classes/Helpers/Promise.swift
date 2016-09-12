final class Promise<T> {
    
    typealias Handler = (T) -> ()
    
    /// handler is dispatched to main queue by default
    func onFulfill(dispatchTo queue: dispatch_queue_t = dispatch_get_main_queue(), handler: Handler) {
        dispatch_async(syncQueue) {
            switch self.state {
            case .notFulfilled, .fulfilling:
                self.handlers.append({ value in
                    dispatch_async(queue) { handler(value) }
                })
            case .fulfilled(let value):
                handler(value)
            }
        }
    }
    
    func fulfill(value: T) {
        dispatch_async(syncQueue) {
            switch self.state {
            case .notFulfilled:
                self.state = .fulfilled(value)
            case .fulfilling, .fulfilled:
                debugPrint("Promise is \(self.state), ignoring repeated call to `fulfill`")
            }
        }
    }
    
    func fulfill(provideValue: ((T) -> ()) -> ()) {
        dispatch_async(syncQueue) { 
            
            switch self.state {
                
            case .notFulfilled:
                self.state = .fulfilling
            
                provideValue { value in
                    dispatch_async(self.syncQueue) {
                        self.state = .fulfilled(value)
                    }
                }

            case .fulfilling, .fulfilled:
                debugPrint("Promise is \(self.state), ignoring repeated call to `fulfill`")
            }
        }
    }
    
    // MARK: - Private
    
    private let syncQueue = dispatch_queue_create("ru.avito.AvitoMediaPicker.Promise.syncQueue", DISPATCH_QUEUE_SERIAL)
    private var handlers = [Handler]()
    
    private var state = PromiseState<T>.notFulfilled {
        didSet {
            switch state {
            case .fulfilled(let value):
                if self.handlers.count > 0 {
                    self.handlers.forEach { $0(value) }
                    self.handlers.removeAll()
                }
            case .notFulfilled, .fulfilling:
                break
            }
        }
    }
}

private enum PromiseState<T> {
    case notFulfilled
    case fulfilling
    case fulfilled(T)
}