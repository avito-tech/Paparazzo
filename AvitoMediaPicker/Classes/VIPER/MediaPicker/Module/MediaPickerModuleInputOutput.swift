public protocol MediaPickerModuleInput: class {
    // TODO: сюда можно передавать структурку, которая будет кастомизировать UI пикера (цвета, картинки и т.п.)
}

public protocol MediaPickerModuleOutput: class {
    
    func photoPickerDidAddItem(item: MediaPickerItem)
    func photoPickerDidUpdateItem(item: MediaPickerItem)  // crop/apply filter
    func photoPickerDidRemoveItem(item: MediaPickerItem)
    
    func photoPickerDidFinish()
    func photoPickerDidCancel()
}

/// Главная модель, представляющая фотку в пикере
public struct MediaPickerItem: Equatable {
    let identifier: String
    public let image: ImageSource
    
    init(image: ImageSource) {
        self.identifier = NSUUID().UUIDString
        self.image = image
    }
}

public func ==(item1: MediaPickerItem, item2: MediaPickerItem) -> Bool {
    return item1.identifier == item2.identifier
}