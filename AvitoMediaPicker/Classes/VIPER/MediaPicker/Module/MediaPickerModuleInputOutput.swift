public protocol MediaPickerModuleInput: class {
    // TODO: сюда можно передавать структурку, которая будет кастомизировать UI пикера (цвета, картинки и т.п.)
}

public protocol MediaPickerModuleOutput: class {
    
    func mediaPickerDidAddItems(items: [MediaPickerItem])
    func mediaPickerDidUpdateItem(item: MediaPickerItem)  // crop/apply filter
    func mediaPickerDidRemoveItem(item: MediaPickerItem)
    
    func mediaPickerDidFinish(withItems items: [MediaPickerItem])
    func mediaPickerDidCancel()
}

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