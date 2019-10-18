import ImageSource

// TODO: rename everything uniformely
public final class SelectedImageStorage {
    
    private(set) var images: [PhotoLibraryItem]
    private var onChange: (() -> ())?  // TODO: array
    
    init(images: [PhotoLibraryItem] = []) {
        self.images = images
    }
    
    func addItem(_ item: PhotoLibraryItem) {
        images.append(item)
        onChange?()
    }
    
    func removeItem(_ item: PhotoLibraryItem) {
        if let index = images.index(of: item) {
            images.remove(at: index)
            onChange?()
        }
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
