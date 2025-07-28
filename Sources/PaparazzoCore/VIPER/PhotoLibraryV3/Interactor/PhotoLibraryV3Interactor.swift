import Foundation
import ImageSource

protocol PhotoLibraryV3Interactor: AnyObject {
    
    var mediaPickerData: MediaPickerData { get }
    var currentAlbum: PhotoLibraryAlbum? { get }
    var selectedItems: [MediaPickerItem] { get }
    var selectedPhotosStorage: SelectedImageStorage { get }
    
    var onLimitedAccess: (() -> ())? { get set }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ())
    func setCameraOutputNeeded(_: Bool)
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeLimitedAccess(handler: @escaping () -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeCurrentAlbumEvents(handler: @escaping (PhotoLibraryV3AlbumEvent, PhotoLibraryV3ItemSelectionState) -> ())
    
    func isSelected(_: MediaPickerItem) -> Bool
    func selectItem(_: MediaPickerItem) -> PhotoLibraryV3ItemSelectionState
    func replaceSelectedItem(at index: Int, with: MediaPickerItem)
    func deselectItem(_: MediaPickerItem) -> PhotoLibraryV3ItemSelectionState
    func moveSelectedItem(at sourceIndex: Int, to destinationIndex: Int)
    func prepareSelection() -> PhotoLibraryV3ItemSelectionState
    
    func setCurrentAlbum(_: PhotoLibraryAlbum)
    func observeSelectedItemsChange(_: @escaping () -> ())
}

public struct PhotoLibraryV3Item: Equatable {
    
    public var image: ImageSource
    
    init(image: ImageSource) {
        self.image = image
    }
    
    public static func ==(item1: Self, item2: Self) -> Bool {
        return item1.image == item2.image
    }
}

struct PhotoLibraryV3ItemSelectionState {
    
    enum PreSelectionAction {
        case none
        case deselectAll
    }
    
    var isAnyItemSelected: Bool
    var canSelectMoreItems: Bool
    var preSelectionAction: PreSelectionAction
}

enum PhotoLibraryV3AlbumEvent {
    case fullReload([PhotoLibraryV3Item])
    case incrementalChanges(PhotoLibraryV3Changes)
}

struct PhotoLibraryV3Changes {
    
    // Changes must be applied in that order: remove, insert, update, move.
    // Indexes are provided based on this order of operations.
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, item: PhotoLibraryV3Item)]
    let updatedItems: [(index: Int, item: PhotoLibraryV3Item)]
    let movedIndexes: [(from: Int, to: Int)]
    
    let itemsAfterChanges: [PhotoLibraryV3Item]
    
    public init(
        removedIndexes: IndexSet,
        insertedItems: [(index: Int, item: PhotoLibraryV3Item)],
        updatedItems: [(index: Int, item: PhotoLibraryV3Item)],
        movedIndexes: [(from: Int, to: Int)],
        itemsAfterChanges: [PhotoLibraryV3Item]
    ) {
        self.removedIndexes = removedIndexes
        self.insertedItems = insertedItems
        self.updatedItems = updatedItems
        self.movedIndexes = movedIndexes
        self.itemsAfterChanges = itemsAfterChanges
    }
}

