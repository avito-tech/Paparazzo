public struct ImageRequestId: Hashable, Equatable {
    
    internal let int32Value: Int32
    
    // MARK: - Hashable
    public var hashValue: Int {
        return int32Value.hashValue
    }
    
    // MARK: - Equatable
    public static func ==(id1: ImageRequestId, id2: ImageRequestId) -> Bool {
        return id1.int32Value == id2.int32Value
    }
}

// MARK: - Internal

extension Int32 {
    func toImageRequestId() -> ImageRequestId {
        return ImageRequestId(int32Value: self)
    }
}

extension Int {
    func toImageRequestId() -> ImageRequestId {
        return ImageRequestId(int32Value: Int32(self))
    }
}
