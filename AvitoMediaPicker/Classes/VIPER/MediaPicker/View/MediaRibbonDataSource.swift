import UIKit
import AVFoundation

struct MediaRibbonDataSource {
    
    private var mediaPickerItems = [MediaPickerItem]()
    
    // MARK: - MediaRibbonDataSource
    
    var cameraCellVisible: Bool = true {
        didSet {
            if cameraCellVisible != oldValue {
                adjustCameraCellVisibility()
            }
        }
    }
    
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
    
    var onItemsAdd: (([NSIndexPath], () -> ()) -> ())?
    
    mutating func addItems(items: [MediaPickerItem]) {
        
        let insertedIndexes = mediaPickerItems.count ..< mediaPickerItems.count + items.count
        let indexPaths = insertedIndexes.map { NSIndexPath(forItem: $0, inSection: 0) }
        var called = false
        
        func addItems() {
            mediaPickerItems.appendContentsOf(items)
            called = true
        }
        
        onItemsAdd?(indexPaths, addItems)
        
        if !called {
            addItems()
        }
    }
    
    mutating func removeItem(item: MediaPickerItem) {
        if let index = mediaPickerItems.indexOf(item) {
            collectionView?.performNonAnimatedBatchUpdates({
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                self.mediaPickerItems.removeAtIndex(index)
            })
        }
    }
    
    func indexPathForItem(item: MediaPickerItem) -> NSIndexPath? {
        return mediaPickerItems.indexOf(item).flatMap { NSIndexPath(forItem: $0, inSection: 0) }
    }
    
    func indexPathForCameraItem() -> NSIndexPath? {
        let index: Int? = cameraCellVisible ? mediaPickerItems.count : nil
        return index.flatMap { NSIndexPath(forItem: $0, inSection: 0) }
    }
    
    // MARK: - Private
    
    private func adjustCameraCellVisibility() {
        collectionView?.performNonAnimatedBatchUpdates({ 
            if self.cameraCellVisible {
                self.collectionView?.insertItemsAtIndexPaths([self.indexPathForCameraCell()])
            } else {
                self.collectionView?.deleteItemsAtIndexPaths([self.indexPathForCameraCell()])
            }
        })
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}