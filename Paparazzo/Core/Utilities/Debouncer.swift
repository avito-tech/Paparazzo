public protocol Debouncable {
    func debounce(_ closure: @escaping () -> ())
    func cancel()
}

public final class Debouncer: Debouncable {
    private var lastFireTime = DispatchTime(uptimeNanoseconds: 0)
    private let queue: DispatchQueue
    private let delay: TimeInterval
    
    public init(delay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.delay = delay
        self.queue = queue
    }
    
    public func debounce(_ closure: @escaping () -> ()) {
        lastFireTime = DispatchTime.now()
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            if let strongSelf = self {
                let now = DispatchTime.now()
                let when = strongSelf.lastFireTime + strongSelf.delay
                if now >= when {
                    closure()
                }
            }
        }
    }
    
    public func cancel() {
        debounce {}
    }
}
