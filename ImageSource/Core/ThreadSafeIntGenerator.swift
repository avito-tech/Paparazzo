/// Generates non-repetitive integers in a thread-safe manner
class ThreadSafeIntGenerator {
    
    private var nextValue = 1
    private let queue = DispatchQueue(label: "ru.avito.ThreadSafeIntGenerator.queue")
    
    func nextInt() -> Int {
        var value: Int = 0
        queue.sync {
            value = self.nextValue
            self.nextValue += 1
        }
        return value
    }
}
