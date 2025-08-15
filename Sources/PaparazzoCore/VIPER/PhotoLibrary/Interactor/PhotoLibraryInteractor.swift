import Foundation
import ImageSource

protocol PhotoLibraryInteractor: AnyObject {
    
    var currentAlbum: PhotoLibraryAlbum? { get }
    var selectedItems: [PhotoLibraryItem] { get }
    var onLimitedAccess: (() -> ())? { get set }
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeCurrentAlbumEvents(handler: @escaping (PhotoLibraryAlbumEvent, PhotoLibraryItemSelectionState) -> ())
    
    func isSelected(_: PhotoLibraryItem) -> Bool
    func selectItem(_: PhotoLibraryItem) -> PhotoLibraryItemSelectionState
    func deselectItem(_: PhotoLibraryItem) -> PhotoLibraryItemSelectionState
    func prepareSelection() -> PhotoLibraryItemSelectionState
    
    func setCurrentAlbum(_: PhotoLibraryAlbum)
}

public struct PhotoLibraryItem: Equatable {
    
    public var image: ImageSource
    
    init(image: ImageSource) {
        self.image = image
    }
    
    public static func ==(item1: PhotoLibraryItem, item2: PhotoLibraryItem) -> Bool {
        return item1.image == item2.image
    }
    
    var asV3: PhotoLibraryV3Item {
        PhotoLibraryV3Item(image: self.image)
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

enum PhotoLibraryAlbumEvent {
    case fullReload([PhotoLibraryItem])
    case incrementalChanges(PhotoLibraryChanges)
    
    var asV3: PhotoLibraryV3AlbumEvent {
        switch self {
        case let .fullReload(value):
            return .fullReload(value.map { $0.asV3 })
        case let .incrementalChanges(value):
            return .incrementalChanges(value.asV3)
        }
    }
}

struct PhotoLibraryChanges {
    
    // Changes must be applied in that order: remove, insert, update, move.
    // Indexes are provided based on this order of operations.
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, item: PhotoLibraryItem)]
    let updatedItems: [(index: Int, item: PhotoLibraryItem)]
    let movedIndexes: [(from: Int, to: Int)]
    
    let itemsAfterChanges: [PhotoLibraryItem]
    
    var asV3: PhotoLibraryV3Changes {
        PhotoLibraryV3Changes(
            removedIndexes: self.removedIndexes,
            insertedItems: self.insertedItems.map { ($0.0, $0.1.asV3) },
            updatedItems: self.updatedItems.map { ($0.0, $0.1.asV3) },
            movedIndexes: self.movedIndexes,
            itemsAfterChanges: self.itemsAfterChanges.map { $0.asV3 }
        )
    }
}
