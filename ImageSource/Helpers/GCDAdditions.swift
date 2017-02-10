import Foundation

/// Executes block immediately if current thread is main thread. Otherwise queues is for execution via dispatch_async. 
func dispatch_to_main_queue(block: @escaping () -> ()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
