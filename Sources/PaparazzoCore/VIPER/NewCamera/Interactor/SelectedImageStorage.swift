import ImageSource

// TODO: rename everything uniformely
public final class SelectedImageStorage {
    
    private(set) var images: [MediaPickerItem]
    private var onChange: (() -> ())?  // TODO: array
    
    init(images: [MediaPickerItem] = []) {
        self.images = images
    }
    
    func addItem(_ item: MediaPickerItem) {
        images.append(item)
        onChange?()
    }
    
    func removeItem(_ item: MediaPickerItem) {
        if let index = images.firstIndex(of: item) {
            images.remove(at: index)
            onChange?()
        }
    }
    
    @discardableResult
    func replaceItem(at index: Int, with item: MediaPickerItem) -> Bool {
        guard images.indices.contains(index) else { return false }
        images[index] = item
        onChange?()
        return true
    }
    
    func removeAllItems() {
        if !images.isEmpty {
            images.removeAll()
            onChange?()
        }
    }
    
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        images.moveElement(from: sourceIndex, to: destinationIndex)
        onChange?()
    }
    
    func observeImagesChange(_ onChange: @escaping () -> ()) {
        self.onChange = onChange
    }
}
