import Foundation
import AvitoDesignKit

protocol PhotoLibraryInteractor: class {
    
    func authorizationStatus(completion: (accessGranted: Bool) -> ())
    func observeItems(handler: (changes: PhotoLibraryChanges, selectionState: PhotoLibraryItemSelectionState) -> ())
    
    func selectItem(item: PhotoLibraryItem, completion: PhotoLibraryItemSelectionState -> ())
    func deselectItem(item: PhotoLibraryItem, completion: PhotoLibraryItemSelectionState -> ())
    func selectedItems(completion: [PhotoLibraryItem] -> ())
}

public struct PhotoLibraryItem: Equatable {
    
    public var image: ImageSource
    
    var identifier: String
    var selected: Bool
    
    init(identifier: String, image: ImageSource, selected: Bool) {
        self.identifier = identifier
        self.image = image
        self.selected = selected
    }
}

public func ==(item1: PhotoLibraryItem, item2: PhotoLibraryItem) -> Bool {
    return item1.identifier == item2.identifier
}

struct PhotoLibraryItemSelectionState {
    var isAnyItemSelected: Bool
    var canSelectMoreItems: Bool
}

struct PhotoLibraryChanges {
    
    // Изменения применять в таком порядке: удаление, вставка, обновление, перемещение
    let removedIndexes: NSIndexSet
    let insertedItems: [(index: Int, item: PhotoLibraryItem)]
    let updatedItems: [(index: Int, item: PhotoLibraryItem)]
    let movedIndexes: [(from: Int, to: Int)]
    
    let itemsAfterChanges: [PhotoLibraryItem]
}