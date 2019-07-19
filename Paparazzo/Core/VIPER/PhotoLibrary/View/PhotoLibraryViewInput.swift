import Foundation
import ImageSource

protocol PhotoLibraryViewInput: class {
    
    var onTitleTap: (() -> ())? { get set }
    var onDimViewTap: (() -> ())? { get set }
    
    func setTitle(_: String)
    func setTitleVisible(_: Bool)
    
    func setPlaceholderState(_: PhotoLibraryPlaceholderState)
    
    func setItems(_: [PhotoLibraryItemCellData], scrollToBottom: Bool, completion: (() -> ())?)
    func applyChanges(_: PhotoLibraryViewChanges, completion: (() -> ())?)
    
    func setCanSelectMoreItems(_: Bool)
    func setDimsUnselectedItems(_: Bool)
    
    func deselectAllItems()
    
    func scrollToBottom()
    
    func setAlbums(_: [PhotoLibraryAlbumCellData])
    func selectAlbum(withId: String)
    func showAlbumsList()
    func hideAlbumsList()
    func toggleAlbumsList()
    
    var onPickButtonTap: (() -> ())? { get set }
    var onCancelButtonTap: (() -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    
    func setProgressVisible(_ visible: Bool)
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
}

struct PhotoLibraryAlbumCellData {
    let identifier: String
    let title: String
    let coverImage: ImageSource?
    let onSelect: () -> ()
}

struct PhotoLibraryItemCellData: Equatable {
    
    var image: ImageSource
    var selected = false
    var previewAvailable = false
    
    var onSelect: (() -> ())?
    var onSelectionPrepare: (() -> ())?
    var onDeselect: (() -> ())?
    var getSelectionIndex: (() -> Int?)?
    
    init(image: ImageSource, getSelectionIndex: (() -> Int?)? = nil) {
        self.image = image
        self.getSelectionIndex = getSelectionIndex
    }
    
    static func ==(cellData1: PhotoLibraryItemCellData, cellData2: PhotoLibraryItemCellData) -> Bool {
        return cellData1.image == cellData2.image
    }
}

struct PhotoLibraryViewChanges {
    // Изменения применять в таком порядке: удаление, вставка, обновление, перемещение
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, cellData: PhotoLibraryItemCellData)]
    let updatedItems: [(index: Int, cellData: PhotoLibraryItemCellData)]
    let movedIndexes: [(from: Int, to: Int)]
}

enum PhotoLibraryPlaceholderState {
    case hidden
    case visible(title: String)
}
