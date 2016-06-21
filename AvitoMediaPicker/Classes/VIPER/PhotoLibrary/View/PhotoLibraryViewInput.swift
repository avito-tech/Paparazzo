import Foundation

protocol PhotoLibraryViewInput: class {
    
    func setCellsData(items: [PhotoLibraryItemCellData])
    func setCanSelectMoreItems(canSelectMoreItems: Bool)
    func setDimsUnselectedItems(dimUnselectedItems: Bool)
    
    func scrollToBottom()
    
    var onPickButtonTap: (() -> ())? { get set }
}

struct PhotoLibraryItemCellData {
    
    var image: ImageSource
    var selected = false
    
    var onSelect: (() -> ())?
    var onDeselect: (() -> ())?
    
    init(image: ImageSource) {
        self.image = image
    }
}