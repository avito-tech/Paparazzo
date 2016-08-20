import Foundation

/// Executes block immediately if current thread is main thread. Otherwise queues is for execution via dispatch_async. 
func dispatch_to_main_queue(block: dispatch_block_t) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}