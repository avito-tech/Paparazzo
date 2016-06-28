import UIKit
import AVFoundation

final class MediaRibbonDataSource {
    
    typealias DataMutationHandler = (indexPaths: [NSIndexPath], mutatingFunc: () -> ()) -> ()
    
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
    
    var onItemsAdd: DataMutationHandler?
    var onItemsRemove: DataMutationHandler?
    
    func addItems(items: [MediaPickerItem]) {
        
        let insertedIndexes = mediaPickerItems.count ..< mediaPickerItems.count + items.count
        let indexPaths = insertedIndexes.map { NSIndexPath(forItem: $0, inSection: 0) }
        
        invokeMutationHandler(onItemsAdd, indexPaths: indexPaths) { [weak self] in
            self?.mediaPickerItems.appendContentsOf(items)
        }
    }
    
    func removeItem(item: MediaPickerItem) {
        
        guard let index = mediaPickerItems.indexOf(item) else { return }
        
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        
        invokeMutationHandler(onItemsRemove, indexPaths: [indexPath]) { [weak self] in
            self?.mediaPickerItems.removeAtIndex(index)
        }
    }
    
    func indexPathForItem(item: MediaPickerItem) -> NSIndexPath? {
        return mediaPickerItems.indexOf(item).flatMap { NSIndexPath(forItem: $0, inSection: 0) }
    }
    
    func indexPathForCameraItem() -> NSIndexPath {
        return NSIndexPath(forItem: mediaPickerItems.count, inSection: 0)
    }
    
    // MARK: - Private
    
    private func invokeMutationHandler(handler: DataMutationHandler?, indexPaths: [NSIndexPath], mutationFunction: (() -> ())?) {
        
        guard let handler = handler else { return }
        
        var mutationFunctionCalled = false
        
        let mutationFunctionWrapper = {
            mutationFunction?()
            mutationFunctionCalled = true
        }
        
        handler(indexPaths: indexPaths, mutatingFunc: mutationFunctionWrapper)
        
        if let mutationFunction = mutationFunction where !mutationFunctionCalled {
            mutationFunction()
        }
    }
    
    private func adjustCameraCellVisibility() {
        
        let handler = cameraCellVisible ? onItemsAdd : onItemsRemove
        let indexPaths = [indexPathForCameraItem()]
        
        invokeMutationHandler(handler, indexPaths: indexPaths, mutationFunction: nil)
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}