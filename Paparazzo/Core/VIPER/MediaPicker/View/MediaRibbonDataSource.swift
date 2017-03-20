import UIKit

final class MediaRibbonDataSource {
    
    typealias DataMutationHandler = (_ indexPaths: [IndexPath], _ mutatingFunc: () -> ()) -> ()
    
    private var mediaPickerItems = [MediaPickerItem]()
    
    // MARK: - MediaRibbonDataSource
    
    var cameraCellVisible: Bool = true
    
    var numberOfItems: Int {
        return mediaPickerItems.count + (cameraCellVisible ? 1 : 0)
    }
    
    subscript(indexPath: IndexPath) -> MediaRibbonItem {
        if indexPath.item < mediaPickerItems.count {
            return .photo(mediaPickerItems[indexPath.item])
        } else {
            return .camera
        }
    }
    
    func addItems(_ items: [MediaPickerItem]) -> [IndexPath] {
        
        let insertedIndexes = mediaPickerItems.count ..< mediaPickerItems.count + items.count
        let indexPaths = insertedIndexes.map { IndexPath(item: $0, section: 0) }
        
        mediaPickerItems.append(contentsOf: items)
        
        return indexPaths
    }
    
    func updateItem(_ item: MediaPickerItem) -> IndexPath? {
        if let index = mediaPickerItems.index(of: item) {
            mediaPickerItems[index] = item
            return IndexPath(item: index, section: 0)
        } else {
            return nil
        }
    }
    
    func removeItem(_ item: MediaPickerItem) -> IndexPath? {
        if let index = mediaPickerItems.index(of: item) {
            mediaPickerItems.remove(at: index)
            return IndexPath(item: index, section: 0)
        } else {
            return nil
        }
    }
    
    func moveItem(from index: Int, to destinationIndex: Int) {
        mediaPickerItems.moveElement(from: index, to: destinationIndex)
    }
    
    func indexPathForItem(_ item: MediaPickerItem) -> IndexPath? {
        return mediaPickerItems.index(of: item).flatMap { IndexPath(item: $0, section: 0) }
    }
    
    func indexPathForCameraItem() -> IndexPath {
        return IndexPath(item: mediaPickerItems.count, section: 0)
    }
}

enum MediaRibbonItem {
    case photo(MediaPickerItem)
    case camera
}
