/// Generates non-repetitive integers in a thread-safe manner
class ThreadSafeIntGenerator {
    
    private var nextValue = 1
    private let queue = dispatch_queue_create("ru.avito.ThreadSafeIntGenerator.queue", DISPATCH_QUEUE_SERIAL)
    
    func nextInt() -> Int {
        var value: Int = 0
        dispatch_sync(queue) {
            value = self.nextValue
            self.nextValue += 1
        }
        return value
    }
}