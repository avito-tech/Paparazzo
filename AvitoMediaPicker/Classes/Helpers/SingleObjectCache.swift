final class SingleObjectCache<T: AnyObject> {
    
    private let cacheKey = "key"
    private let cache = NSCache()
    
    var value: T? {
        get {
            return cache.objectForKey(cacheKey) as? T
        }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: cacheKey)
            } else {
                cache.removeObjectForKey(cacheKey)
            }
        }
    }
}