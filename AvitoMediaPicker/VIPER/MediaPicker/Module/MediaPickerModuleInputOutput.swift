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
public struct MediaPickerItem {
    let image: ImageSource
}
