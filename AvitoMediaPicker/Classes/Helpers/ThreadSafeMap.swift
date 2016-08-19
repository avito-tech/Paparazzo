struct ThreadSafeMap<KeyType: Hashable, ValueType> {
    
    private var dictionary = [KeyType: ValueType]()
    private let queue = dispatch_queue_create("ru.avito.ThreadSafeMap.queue", DISPATCH_QUEUE_SERIAL)
    
    subscript(key: KeyType) -> ValueType? {
        get {
            var value: ValueType?
            dispatch_sync(queue) {
                value = self.dictionary[key]
            }
            return value
        }
        set {
            dispatch_sync(queue) {
                self.dictionary[key] = newValue
            }
        }
    }
}