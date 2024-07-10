import Foundation

final class SingleObjectCache<T: AnyObject> {
    
    private let cacheKey = "key" as NSString
    private let cache = NSCache<NSString, T>()
    
    init(value: T? = nil) {
        self.value = value
    }
    
    var value: T? {
        get {
            return cache.object(forKey: cacheKey)
        }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: cacheKey)
            } else {
                cache.removeObject(forKey: cacheKey)
            }
        }
    }
}
