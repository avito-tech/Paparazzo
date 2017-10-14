import Foundation
import ImageSource

protocol PhotoLibraryViewInput: class {
    
    var onTitleTap: (() -> ())? { get set }
    var onDimViewTap: (() -> ())? { get set }
    
    func setTitle(_: String)
    
    func applyChanges(_: PhotoLibraryViewChanges, animated: Bool, completion: (() -> ())?)
    
    func setCanSelectMoreItems(_: Bool)
    func setDimsUnselectedItems(_: Bool)
    
    func deselectAllItems()
    
    func scrollToBottom()
    
    func showAlbumsList()
    func hideAlbumsList()
    func toggleAlbumsList()
    
    var onPickButtonTap: (() -> ())? { get set }
    var onCancelButtonTap: (() -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    
    func setProgressVisible(_ visible: Bool)
    func setAlbums(_: [PhotoLibraryAlbumCellData])
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
}

struct PhotoLibraryAlbumCellData {
    let title: String
    let coverImage: ImageSource?
    let onSelect: () -> ()
}

struct PhotoLibraryItemCellData {
    
    var image: ImageSource
    var selected = false
    var previewAvailable = false
    
    var onSelect: (() -> ())?
    var onSelectionPrepare: (() -> ())?
    var onDeselect: (() -> ())?
    
    init(image: ImageSource) {
        self.image = image
    }
}

struct PhotoLibraryViewChanges {
    // Изменения применять в таком порядке: удаление, вставка, обновление, перемещение
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, cellData: PhotoLibraryItemCellData)]
    let updatedItems: [(index: Int, cellData: PhotoLibraryItemCellData)]
    let movedIndexes: [(from: Int, to: Int)]
}
