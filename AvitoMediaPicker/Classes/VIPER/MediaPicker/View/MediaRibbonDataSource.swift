import UIKit
import AVFoundation

final class MediaRibbonDataSource {
    
    typealias DataMutationHandler = (indexPaths: [NSIndexPath], mutatingFunc: () -> ()) -> ()
    
    private var mediaPickerItems = [MediaPickerItem]()
    
    // MARK: - MediaRibbonDataSource
    
    var cameraCellVisible: Bool = true
    
    var numberOfItems: Int {
        return mediaPickerItems.count + (cameraCellVisible ? 1 : 0)
    }
    
    subscript(indexPath: NSIndexPath) -> MediaRibbonItem {
        if indexPath.item < mediaPickerItems.count {
            return .Photo(mediaPickerItems[indexPath.item])
        } else {
            return .Camera
        }
    }
    
    func addItems(items: [MediaPickerItem]) -> [NSIndexPath] {
        
        let insertedIndexes = mediaPickerItems.count ..< mediaPickerItems.count + items.count
        let indexPaths = insertedIndexes.map { NSIndexPath(forItem: $0, inSection: 0) }
        
        mediaPickerItems.appendContentsOf(items)
        
        return indexPaths
    }
    
    func updateItem(item: MediaPickerItem) -> NSIndexPath? {
        if let index = mediaPickerItems.indexOf(item) {
            mediaPickerItems[index] = item
            return NSIndexPath(forItem: index, inSection: 0)
        } else {
            return nil
        }
    }
    
    func removeItem(item: MediaPickerItem) -> NSIndexPath? {
        if let index = mediaPickerItems.indexOf(item) {
            mediaPickerItems.removeAtIndex(index)
            return NSIndexPath(forItem: index, inSection: 0)
        } else {
            return nil
        }
    }
    
    func indexPathForItem(item: MediaPickerItem) -> NSIndexPath? {
        return mediaPickerItems.indexOf(item).flatMap { NSIndexPath(forItem: $0, inSection: 0) }
    }
    
    func indexPathForCameraItem() -> NSIndexPath {
        return NSIndexPath(forItem: mediaPickerItems.count, inSection: 0)
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}