import AvitoDesignKit

/// Главная модель, представляющая фотку в пикере
public struct MediaPickerItem: Equatable {
    
    public enum Source {
        case Camera
        case PhotoLibrary
    }
 
    public let image: ImageSource
    public let source: Source
    
    let identifier: String
    
    public init(identifier: String = NSUUID().UUIDString, image: ImageSource, source: Source) {
        self.identifier = identifier
        self.image = image
        self.source = source
    }
}

public func ==(item1: MediaPickerItem, item2: MediaPickerItem) -> Bool {
    return item1.identifier == item2.identifier
}