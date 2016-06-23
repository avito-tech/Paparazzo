/// Главная модель, представляющая фотку в пикере
public struct MediaPickerItem: Equatable {
    let identifier: String
    public let image: ImageSource
    
    init(identifier: String = NSUUID().UUIDString, image: ImageSource) {
        self.identifier = identifier
        self.image = image
    }
}

public func ==(item1: MediaPickerItem, item2: MediaPickerItem) -> Bool {
    return item1.identifier == item2.identifier
}