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
            return IndexPath(item: index, section: 0)
        } else {
            return nil
        }
    }
    
    func indexPathForItem(item: MediaPickerItem) -> IndexPath? {
        return mediaPickerItems.index(of: item).flatMap { IndexPath(item: $0, section: 0) }
    }
    
    func indexPathForCameraItem() -> IndexPath {
        return IndexPath(item: mediaPickerItems.count, section: 0)
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}
