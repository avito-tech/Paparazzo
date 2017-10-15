import Foundation
import ImageSource

protocol PhotoLibraryInteractor: class {
    
    var selectedItems: [PhotoLibraryItem] { get }
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeEvents(
        in: PhotoLibraryAlbum,
        handler: @escaping (_ event: PhotoLibraryEvent, _ selectionState: PhotoLibraryItemSelectionState) -> ())
    
    func isSelected(_: PhotoLibraryItem) -> Bool
    func selectItem(_: PhotoLibraryItem) -> PhotoLibraryItemSelectionState
    func deselectItem(_: PhotoLibraryItem) -> PhotoLibraryItemSelectionState
    func prepareSelection() -> PhotoLibraryItemSelectionState
}

public struct PhotoLibraryItem: Equatable {
    
    public var image: ImageSource
    
    var identifier: String
    
    init(identifier: String, image: ImageSource) {
        self.identifier = identifier
        self.image = image
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
    case initialLoad([PhotoLibraryItem])
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
