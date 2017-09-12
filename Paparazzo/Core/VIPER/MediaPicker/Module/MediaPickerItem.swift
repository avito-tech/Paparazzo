import ImageSource

/// Главная модель, представляющая фотку в пикере
public final class MediaPickerItem: Equatable {
    
    public enum Source {
        case camera
        case photoLibrary
    }
 
    public let image: ImageSource
    public let source: Source
    
    let identifier: String
    
    let originalItem: MediaPickerItem?
    
    public init(
        identifier: String = NSUUID().uuidString,
        image: ImageSource,
        source: Source,
        originalItem: MediaPickerItem? = nil)
    {
        self.identifier = identifier
        self.image = image
        self.source = source
        self.originalItem = originalItem
    }
    
    public static func ==(item1: MediaPickerItem, item2: MediaPickerItem) -> Bool {
        return item1.identifier == item2.identifier
    }
}
