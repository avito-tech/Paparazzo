import Foundation

class AsynchronousOperation: NSOperation {
    
    // MARK: - NSOperation
    
    override var asynchronous: Bool {
        return true
    }
    
    override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    // MARK: - AsynchronousOperation
    
    enum State {
        
        case Ready, Executing, Finished
        
        var keyPath: String {
            switch self {
            case Ready:
                return "isReady"
            case Executing:
                return "isExecuting"
            case Finished:
                return "isFinished"
            }
        }
    }
    
    var state = State.Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath)
            willChangeValueForKey(state.keyPath)
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath)
            didChangeValueForKey(state.keyPath)
        }
    }
}

extension qos_class_t {
    init(_ qos: NSQualityOfService) {
        switch qos {
        case .UserInteractive:
            self = QOS_CLASS_USER_INTERACTIVE
        case .UserInitiated:
            self = QOS_CLASS_USER_INITIATED
        case .Utility:
            self = QOS_CLASS_UTILITY
        case .Background:
            self = QOS_CLASS_BACKGROUND
        case .Default:
            self = QOS_CLASS_DEFAULT
        }
    }
}