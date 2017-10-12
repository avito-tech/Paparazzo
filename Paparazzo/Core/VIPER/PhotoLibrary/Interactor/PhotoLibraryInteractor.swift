import Foundation
import ImageSource

protocol PhotoLibraryInteractor: class {
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeItems(handler: @escaping (_ changes: PhotoLibraryChanges, _ selectionState: PhotoLibraryItemSelectionState) -> ())
    
    func selectItem(_: PhotoLibraryItem, completion: @escaping (PhotoLibraryItemSelectionState) -> ())
    func deselectItem(_: PhotoLibraryItem, completion: @escaping (PhotoLibraryItemSelectionState) -> ())
    func prepareSelection(completion: @escaping (PhotoLibraryItemSelectionState) -> ())
    func selectedItems(completion: @escaping ([PhotoLibraryItem]) -> ())
}

public struct PhotoLibraryItem: Equatable {
    
    public var image: ImageSource
    
    var identifier: String
    var selected: Bool
    
    init(identifier: String, image: ImageSource, selected: Bool = false) {
        self.identifier = identifier
        self.image = image
        self.selected = selected
    }
}

public func ==(item1: PhotoLibraryItem, item2: PhotoLibraryItem) -> Bool {
    return item1.identifier == item2.identifier
}

struct PhotoLibraryItemSelectionState {
    
    enum PreSelectionAction {
        case none
        case deselectAll
    }
    
    var isAnyItemSelected: Bool
    var canSelectMoreItems: Bool
    var preSelectionAction: PreSelectionAction
}

struct PhotoLibraryChanges {
    
    // Изменения применять в таком порядке: удаление, вставка, обновление, перемещение
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, item: PhotoLibraryItem)]
    let updatedItems: [(index: Int, item: PhotoLibraryItem)]
    let movedIndexes: [(from: Int, to: Int)]
    
    let itemsAfterChanges: [PhotoLibraryItem]
}
