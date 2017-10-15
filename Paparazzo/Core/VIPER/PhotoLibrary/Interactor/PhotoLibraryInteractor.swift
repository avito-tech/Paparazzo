import Foundation
import ImageSource

protocol PhotoLibraryInteractor: class {
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(
        in: PhotoLibraryAlbum,
        handler: @escaping (_ event: PhotoLibraryEvent, _ selectionState: PhotoLibraryItemSelectionState) -> ())
    
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
    
    public static func ==(item1: PhotoLibraryItem, item2: PhotoLibraryItem) -> Bool {
        return item1.identifier == item2.identifier
    }
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

enum PhotoLibraryEvent {
    case fullReload([PhotoLibraryItem])
    case changes(PhotoLibraryChanges)
}

struct PhotoLibraryChanges {
    
    // Changes must be applied in that order: remove, insert, update, move
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, item: PhotoLibraryItem)]
    let updatedItems: [(index: Int, item: PhotoLibraryItem)]
    let movedIndexes: [(from: Int, to: Int)]
    
    let itemsAfterChanges: [PhotoLibraryItem]
}
