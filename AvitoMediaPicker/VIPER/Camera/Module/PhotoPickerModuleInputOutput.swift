public protocol PhotoPickerModuleInput: class {
    // TODO: сюда можно передавать структурку, которая будет кастомизировать UI пикера (цвета, картинки и т.п.)
}

public protocol PhotoPickerModuleOutput: class {
    
    func photoPickerDidAddItem(item: PhotoPickerItem)
    func photoPickerDidUpdateItem(item: PhotoPickerItem)  // crop/apply filter
    func photoPickerDidRemoveItem(item: PhotoPickerItem)
    
    func photoPickerDidFinish()
    func photoPickerDidCancel()
}

/// Главная модель, представляющая фотку в пикере
public struct PhotoPickerItem {
    let image: LazyImage
}
