import UIKit
import AVFoundation

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
            return .Photo(mediaPickerItems[indexPath.item])
        } else {
            return .Camera
        }
    }
    
    func addItems(items: [MediaPickerItem]) -> [IndexPath] {
        
        let insertedIndexes = mediaPickerItems.count ..< mediaPickerItems.count + items.count
        let indexPaths = insertedIndexes.map { IndexPath(item: $0, section: 0) }
        
        mediaPickerItems.append(contentsOf: items)
        
        return indexPaths
    }
    
    func updateItem(item: MediaPickerItem) -> IndexPath? {
        if let index = mediaPickerItems.index(of: item) {
            mediaPickerItems[index] = item
            return IndexPath(item: index, section: 0)
        } else {
            return nil
        }
    }
    
    func removeItem(item: MediaPickerItem) -> IndexPath? {
        if let index = mediaPickerItems.index(of: item) {
            mediaPickerItems.remove(at: index)
            return IndexPath(forItem: index, inSection: 0)
        } else {
            return nil
        }
    }
    
    func indexPathForItem(item: MediaPickerItem) -> IndexPath? {
        return mediaPickerItems.indexOf(item).flatMap { IndexPath(forItem: $0, inSection: 0) }
    }
    
    func indexPathForCameraItem() -> IndexPath {
        return IndexPath(forItem: mediaPickerItems.count, inSection: 0)
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}
