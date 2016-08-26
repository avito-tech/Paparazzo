import Foundation
import AvitoDesignKit

protocol PhotoLibraryViewInput: class {
    
    func setTitle(_: String)
    func setCancelButtonTitle(_: String)
    func setDoneButtonTitle(_: String)
    
    func applyChanges(_: PhotoLibraryViewChanges, animated: Bool, completion: (() -> ())?)
    
    func setCanSelectMoreItems(canSelectMoreItems: Bool)
    func setDimsUnselectedItems(dimUnselectedItems: Bool)
    func setPickButtonEnabled(_: Bool)
    
    func scrollToBottom()
    
    var onPickButtonTap: (() -> ())? { get set }
    var onCancelButtonTap: (() -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
}

struct PhotoLibraryItemCellData {
    
    var image: ImageSource
    var selected = false
    var previewAvailable = false
    
    var onSelect: (() -> ())?
    var onDeselect: (() -> ())?
    
    init(image: ImageSource) {
        self.image = image
    }
}

struct PhotoLibraryViewChanges {
    // Изменения применять в таком порядке: удаление, вставка, обновление, перемещение
    let removedIndexes: NSIndexSet
    let insertedItems: [(index: Int, cellData: PhotoLibraryItemCellData)]
    let updatedItems: [(index: Int, cellData: PhotoLibraryItemCellData)]
    let movedIndexes: [(from: Int, to: Int)]
}