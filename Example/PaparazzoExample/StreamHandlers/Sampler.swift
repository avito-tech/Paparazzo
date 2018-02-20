import Foundation

public final class Sampler {
    // MARK: - Public properties
    
    public let delay: TimeInterval
    
    // MARK: - Private properties
    
    private let queue: DispatchQueue
    private var closure: (() -> ())?
    private var isDelaying = false
    
    // MARK: - Init
    
    public init(delay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.delay = delay
        self.queue = queue
    }
    
    // MARK: - Public
    
    public func sample(_ closure: @escaping () -> ()) {
        if isDelaying {
            self.closure = closure
        } else {
            queue.async {
                closure()
            }
            self.closure = nil
            isDelaying = true
            queue.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.isDelaying = false
                if let closure = strongSelf.closure {
                    strongSelf.sample(closure)
                }
            }
        }
    }
}

